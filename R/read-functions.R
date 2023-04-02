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
#' @return A `tibble()`. Side effects are committing and pushing the updated
#' MD5 hash overview to GitHub in case of first-time data access.
#' @export
read_data <- function(file, read_fun, col_select = NULL, row_filter = NULL, row_shuffle = NULL, long_format = FALSE, seed = 3985843, ...) {

  # Validate input

  if(!file.exists(file)) {
    cli::cli_abort("file not found in directory.")
  }

  if(stringr::str_detect(read_fun, "::", negate = TRUE)) {
    if(!read_fun %in% ls("package:readr")) {
      cli::cli_abort("{read_fun} is not a valid function in package `readr`. Check your input for typos. If the function is part of another package than `readr`, specify the package name explicitly (e.g., 'haven::read_spss')")
    } else {
      cli::cli_alert_info("Using function {read_fun}() from the `readr` package.")
    }
  } else {
    input <- strsplit(read_fun, "::")

    tryCatch(
      input[[1]][1] %in% .packages(TRUE),
      error = cli::cli_abort("There is no package called '{input[[1]][1]}'. Try install.packages('{input[[1]][1]}') first.")
    )

    if(!input[[1]][1] %in% .packages(TRUE)) {
      cli::cli_abort("Package `{input[[1]][1]}` not found. Try install_packages('{input[[1]][1]}') first.")
    }
    if(!input[[1]][2] %in% ls(glue::glue("package:{input[[1]][1]}"))) {
      cli::cli_abort("'{input[[1]][2]}' is not a valid function in package `{input[[1]][1]}`. Did you make a typo?")
    }

    cli::cli_alert_info("Using function {input[[1]][2]}() from the '{input[[1]][1]}' package.")
  }


  # Capture and tidy dots
  dots <- list(...)

  if(length(dots) > 0) {
    dots_chr <- 1:length(dots) |>
      purrr::map(function(x) {
        paste0(names(dots[x]), " = ", dots[[x]])
      }) |>
      purrr::compact() |>
      paste(collapse = ", ")
  } else {
    dots_chr = ""
  }

  # Capture data read and manipulation inputs
  col_select = paste0("col_select = ", ifelse(!is.null(col_select), as.character(col_select), "NULL"))
  row_shuffle = ifelse(is.null(row_shuffle), "NULL", row_shuffle)

  code <- list()

  code$read = ifelse(grepl(x = read_fun, pattern = "::"), read_fun, paste0("readr::", read_fun)) |>
    paste0("('", file, "', ", col_select, ", ", dots_chr, ")")
  code$filter = paste0("dplyr::filter(", as.character(row_filter), ")")
  code$shuffle = paste0("shuffle(data = _, shuffle_vars = ", row_shuffle, ", long_format = ", long_format, ", seed = ", seed, ")")


  pipeline_chr <- code |>
    paste(collapse = " |> ")

  cli::cli_alert_info("The following code will be executed: {pipeline_chr}", wrap = T)

  # Execute code
  data <- pipeline_chr |>
    glue::glue(.trim = F) |>
    rlang::parse_expr() |>
    rlang::eval_tidy()

  # Check whether data has been accessed before

  cli::cli_h1("Check for first-time data access")
  data_hash <- digest::digest(data)

  committed_hashes <-
    gert::git_log()$message |>
    grep(pattern = "MILESTONE data_access", x = _, value = TRUE) |>
    (\(.) regmatches(x = ., m = gregexpr("[a-z0-9]{32}", text = .)))() |>
    unlist()

  cli::cli_alert_info("{length(committed_hashes)} previously committed data files found.")

  if(!data_hash %in% committed_hashes) {

    response = FALSE

    while(response != 'Y' & response != "n") {
      response <- readline(prompt = "NEW DATA FILE DETECTED. This will trigger an automatic commit to GitHub. Are you sure you want to continue? [Y/n]:")
    }

    if(response == "n") {
      return(cli::cli_alert_info("Reading the data file was aborted."))
    }

    cli::cli_h1("Commit data access milestone to GitHub")

    message <- readline(prompt = "If you want, you can type a short commit message with more details about the data file. Press enter for a default message: ")


    # Construct commit message
    commit_code <- glue::glue("code {pipeline_chr}")
    commit_hash <- glue::glue("object_hash {data_hash}")
    commit_message <- glue::glue("{message}\n{commit_hash}\n{commit_code}")

    cli::cli_alert_info("The following commit message will be used: {commit_message}")

    readr::read_file("project_log/MD5") |>
      paste(data_hash, sep = "\n") |>
      readr::write_file("project_log/MD5")

    tryCatch(
      log_milestone("project_log/MD5", milestone_type = "data_access", commit_message = commit_message),
      error = function(e) {
        readr::read_file("project_log/MD5") |>
          gsub(x = _, pattern = paste0("\n", data_hash), replacement = "") |>
          readr::write_file("project_log/MD5")
        cli::cli_abort("Failed to commit data access to remote GitHub repository. Reverting changes to MD5 file...")
      }
    )

    return(data)
  }
  cli::cli_alert_info("Data file was accessed before, so no commit will be initiated.")
  return(data)
}






