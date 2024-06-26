#' @title Read a data file into a tibble and log data access on GitHub
#' @description This is a wrapper around any specified function for
#' reading in data files. Upon accessing the data file, it checks the file
#' against the history of previously accessed data files (through its MD5 hash)
#' to assess whether it constitutes first-time access to the data. If so, it
#' automatically logs this event on GitHub (after prompting the user). This is
#' useful if you want to show in your log that you accessed parts of your data
#' in a particular order (e.g., you first accessed your independent variables
#' to establish an analysis plan and only then accessed your dependent variables).
#' @param file Either a path to a file, a connection, or literal data (either a
#' single string or a raw vector).
#' @param read_fun The name of a function to read data. for 'readr' functions,
#' you only have to specify the function name (e.g., `read_csv()`). If you use
#' a function from another package, name the package explicitly
#' (e.g., `haven::read_spss()`).
#' @param col_select Columns to include in the results. You can use the same
#' mini-language as `dplyr::select()` to refer to the columns by name. Use `c()`
#' to use more than one selection expression. Although this usage is less common,
#' col_select also accepts a numeric column index. See ?tidyselect::language
#' for full details on the selection language.
#' @param row_filter Optional rows to include in the results. Uses `dplyr::filter()`.
#' @param row_shuffle Optional variables to randomly shuffle.
#' @param long_format Logical indicating whether the data are in long format
#' (only relevant when shuffling variables using row_shuffle).
#' @param seed integer used for replicability purposes when randomly shuffling
#' data.
#' @param ... Additional arguments for the read function.
#' @return A `tibble()`. Side effects are committing and pushing the updated
#' MD5 hash overview to GitHub in case of first-time data access.
#' @export
read_data <- function(file, read_fun, col_select = NULL, row_filter = NULL, row_shuffle = NULL, long_format = FALSE, seed = 3985843, ...) {

  read_fun <- read_fun |> gsub(pattern="\\(|\\)", replacement = "")

  validate_fun(file = file, read_fun = read_fun)

  dots <- list(...)

  if(length(dots) > 0) {
    dots_chr <- 1:length(dots) |>
      lapply(function(x) {
        paste0(names(dots[x]), " = '", dots[[x]], "'")
      }) |>
      purrr::compact() |>
      paste(collapse = ", ") |>
      (\(.)  paste(', ', .))()

  } else {
    dots_chr = ""
  }

  # Execute code
  pipeline_chr <- construct_code(file, col_select, read_fun, row_filter, row_shuffle, long_format, seed, dots_chr)
  data <- pipeline_chr |>
   # glue::glue(.trim = F) |>
    rlang::parse_expr() |>
    rlang::eval_tidy()

  cli::cli_h1("Check for first-time data access")
  data_hash <- digest::digest(data)

  committed_hashes <- check_data_access()

  cli::cli_alert_info("{length(committed_hashes)} previously committed data files found.")

  if(!data_hash %in% committed_hashes) {
    if(usethis::ui_yeah("NEW DATA FILE DETECTED. This will trigger an automatic commit to GitHub. Are you sure you want to continue?")) {
      cli::cli_h1("Commit data access milestone to GitHub")
      message <- readline(prompt = "If you want, you can type a short commit message with more details about the data file. Press enter for a default message: ")
      message <- gsub(x = message, pattern = "\'|\"", replacement = "")
    } else {
      return(cli::cli_alert_info("Reading the data file was aborted."))
    }

    # Construct commit message
    commit_code <- glue::glue("code {pipeline_chr}")
    commit_hash <- glue::glue("object_hash {data_hash}")
    commit_message <- glue::glue("{message}\n{commit_hash}\n{commit_code}")

    cli::cli_alert_info("The following commit message will be used: {commit_message}")

    readr::write_file(file = ".projectlog/MD5", x = paste("\n", data_hash), append = TRUE)



    matching_tags <- count_matching_tags(tag = "data_access")

    if(matching_tags > 0) {
      tag <- paste0("data_access",matching_tags)
    } else {
      tag <- "data_access"
    }

    gert::git_add(".projectlog/MD5")

    commit <- validate_commit(commit_message)

    tryCatch(
      {
        gert::git_tag_create(name = tag, message = '', ref = commit, repo = '.')
        gert::git_tag_push(name = tag, repo = ".")
        gert::git_push()
      },
      error = function(e) {
        readr::read_file(".projectlog/MD5") |>
          gsub(x = _, pattern = paste0("\n", data_hash), replacement = "") |>
          readr::write_file(".projectlog/MD5")
        cli::cli_abort("Failed to commit data access to remote GitHub repository. Reverting changes to MD5 file...")
      }
    )

    return(data)
  }
  cli::cli_alert_info("Data file was accessed before, so no commit will be initiated.")
  return(data)

}


#' Shuffle variables in data.
#' @param data Tibble or data.frame.
#' @param shuffle_vars Vector, Names of variables that should be shuffled.
#' @param long_format Logical, Is data in long-format (TRUE) or in wide-format (FALSE)?
#' @param seed Character, Random seed to make sure shuffling is identical in subsequent `read_data()` calls.
#' @keywords internal
shuffle <- function(data, shuffle_vars, long_format, seed = seed) {

  if(is.null(shuffle_vars)) {
    return(data)
  }

  if(long_format) {
    row_nums <- data |> dplyr::group_by_at(shuffle_vars[[1]]) |> dplyr::summarise(n = dplyr::n()) |> dplyr::pull(.data$n)
  } else {
    row_nums <- rep(1, nrow(data))
  }

  set.seed(seed)

  data <- shuffle_vars |>
    lapply(function(x){
      data |>
        dplyr::select(tidyselect::matches(x)) |>
        dplyr::mutate(rows = rep(1:length(row_nums), row_nums)) |>
        dplyr::group_split(.data$rows) |>
        sample() |>
        dplyr::bind_rows() |>
        dplyr::select(-.data$rows)
    }) |>
    do.call("cbind", args = _) |>
    dplyr::bind_cols(
      data |>
        dplyr::select(-tidyselect::matches(shuffle_vars))
    ) |>
    dplyr::select(names(data)) |>
    dplyr::arrange(dplyr::across(tidyselect::matches(shuffle_vars[[1]])))

  data
}

#' Validate read function used in projectlog::initiate_project()
#' @param file Character, path to data file.
#' @param read_fun Character, name of function to read data.
#' @keywords internal
validate_fun <- function(file, read_fun) {

  if(stringr::str_detect(file, "list.files", negate = T)) {
    if(!file.exists(file)) {
      cli::cli_abort("The file {cli::col_blue(file.path(getwd(), file))} was not found in your project directory.")
    }
  }

  if(stringr::str_detect(file, "list.files")) {
    all_files <- file |> rlang::parse_expr() |>rlang::eval_tidy()
    files_exist <- lapply(all_files, file.exists)


    if(!all(files_exist |> unlist())) {
      error_files <- all_files[files_exist == FALSE]
      cli::cli_abort("The following files were not found in your project directory:{cli::col_blue(error_files)}.")
    }
  }


  if(stringr::str_detect(read_fun, "::", negate = TRUE)) {
    if(!read_fun %in% ls("package:readr")) {
      cli::cli_abort(paste0(cli::col_blue("`{read_fun}()`"), " is not a valid function in package ", cli::col_red("`readr`"),". Check your input for typos. If the function is part of another package than ", cli::col_red("`readr`"),", specify the package name explicitly (e.g., '", cli::col_red('haven::read_spss'),"')."))
    } else {
      cli::cli_alert_info(paste("Using function", cli::col_blue('`{read_fun}`'), "from the", cli::col_red('`readr`'), "package."))
    }
  } else {
    input <- strsplit(read_fun, "::")

    if(!paste0("package:", input[[1]][[1]]) %in% search()) {
      cli::cli_abort(paste0("Package ", cli::col_red('`{input[[1]][1]}`'), " has not been loaded yet. Try 'library('{input[[1]][1]}')' first."))
    }

    if(!input[[1]][1] %in% .packages(TRUE)) {
      cli::cli_abort(paste0("Package ", cli::col_red('`{input[[1]][1]}`'), " not found. Try 'install_packages('{input[[1]][1]}')' first."))
    }
    if(!input[[1]][2] %in% ls(glue::glue("package:{input[[1]][1]}"))) {
      cli::cli_abort(paste0(cli::col_blue("'{input[[1]][2]}'"), " is not a valid function in package ", cli::col_red('`{input[[1]][1]}`'), ". Did you make a typo?"))
    }

    cli::cli_alert_info(paste0("Using function ", cli::col_blue('{input[[1]][2]}()'), " from the '{input[[1]][1]}' package."))
  }

  TRUE
}

#' Construct code that is used to read new data
#' @param read_fun The name of a function to read data. for 'readr' functions,
#' you only have to specify the function name (e.g., `read_csv()`). If you use
#' a function from another package, name the package explicitly
#' (e.g., `haven::read_spss()`).
#' @param col_select Columns to include in the results. You can use the same
#' mini-language as `dplyr::select()` to refer to the columns by name. Use `c()`
#' to use more than one selection expression. Although this usage is less common,
#' col_select also accepts a numeric column index. See ?tidyselect::language
#' for full details on the selection language.
#' @param row_filter Optional rows to include in the results. Uses `dplyr::filter()`.
#' @param row_shuffle Optional variables to randomly shuffle.
#' @param long_format Logical indicating whether the data are in long format
#' (only relevant when shuffling variables using row_shuffle).
#' @param seed integer used for replicability purposes when randomly shuffling
#' data.
#' @param dots_chr Additional arguments for the read function, parsed as a string
#' @keywords internal
construct_code <- function(file, col_select, read_fun, row_filter, row_shuffle, long_format, seed, dots_chr){

  # Capture data read and manipulation inputs
  col_select = paste0("col_select = ", ifelse(!is.null(col_select), paste0("'", as.character(col_select), "'"), "NULL"))
  row_shuffle = ifelse(is.null(row_shuffle), "NULL", row_shuffle)



  code <- list()

  if(stringr::str_detect(file, "list.files", negate = T)) {
    code$read = ifelse(grepl(x = read_fun, pattern = "::"), read_fun, paste0("readr::", read_fun)) |>
      paste0("('", file, "', ", col_select, dots_chr, ")")
    code$filter = paste0("dplyr::filter(", as.character(row_filter), ")")
    code$shuffle = paste0("shuffle(data = _, shuffle_vars = '", row_shuffle, "', long_format = ", long_format, ", seed = ", seed, ")")

    pipeline_chr <- code |>
      paste(collapse = " |> ")
  }

  if(stringr::str_detect(file, "list.files")) {
    code$read = paste0(
      "purrr::map(.x = ",
      file, ", function(x) {",
      ifelse(grepl(x = read_fun, pattern = "::"), read_fun, paste0("readr::", read_fun)),
      "(file = x, ", col_select, dots_chr, ")"
    )

    code$filter = paste0("dplyr::filter(", as.character(row_filter), ")")
    code$shuffle = paste0("shuffle(data = _, shuffle_vars = '", row_shuffle, "', long_format = ", long_format, ", seed = ", seed, ")")

    pipeline_chr <- code |>
      paste(collapse = " |> ") |> paste0("})")
  }



  cli::cli_alert_info("The following code will be executed: {pipeline_chr}", wrap = T)

  pipeline_chr
}

#' Check whether data was accessed previously
#' @param data_hash MD5 hash of the current data object (after any modifications).
#' @keywords internal
check_data_access <- function(data_hash) {
  previous_commits <-
    gert::git_tag_list() |>
    dplyr::filter(stringr::str_detect(.data$name, "data_access")) |>
    dplyr::pull(.data$commit) |>
    lapply(function(x){
      gert::git_commit_info(ref = x) |>
        tidyr::as_tibble()
    }) |>
    do.call("rbind", args = _)

  gert::git_log(max = 10000) |>
    dplyr::filter(.data$commit %in% previous_commits$id) |>
    dplyr::pull(.data$message) |>
    (\(.) regmatches(x = ., m = gregexpr("[a-z0-9]{32}", text = .)))() |>
    unlist()
}
