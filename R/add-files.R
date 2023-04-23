#' Add README file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_readme <- function(path) {
  copy_resource(file = 'README.Rmd', from = 'rmd', to = path)
  cli::cli_alert_success(paste("README file:", cli::col_blue("README.Rmd")))
}

#' Add preregistration file to project
#' @param path Character, path to project repository.
#' @param template Character, preregistration template to be used.
#' @keywords internal
add_preregistration <- function(path, template) {

  prereg_path <- grep(x = list.dirs(path = path), pattern = "preregistrations", value = T)
  if(!template %in% c("empty", "secondary")) {
    rmarkdown::draft(
      file = file.path(prereg_path, "preregistration.Rmd"),
      template = paste0(template, "_prereg"),
      package = "prereg",
      edit = FALSE
    )
  } else {
    if(template == "empty") {
      copy_resource(file = "prereg_empty.rmd", from = "rmd", to = prereg_path)
    }

    if(template == "secondary") {
      copy_resource(file = "secondary.rmd", from = "rmd", to = prereg_path)
    }
  }
  cli::cli_alert_success(paste("Preregistration:", cli::col_blue(file.path(prereg_path, "preregistation.Rmd"))))
}


#' Add Registered Report file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_registered_report <- function(path) {
  rr_path <- grep(x = list.dirs(path = path), pattern = "registered_report", value = T)
  copy_resource(file = "registered_report.Rmd", from = "rmd", to = rr_path)
  cli::cli_alert_success(paste("Registered Report:", cli::col_blue(file.path(rr_path, "registered_report.Rmd"))))
}


#' Add .Rproj file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_rproj <- function(path) {

  proj_name <-
    regexpr(pattern = "([a-z]|[0-9]|-|_)*$", text = path) |>
    regmatches(m = _, x = path) |>
    paste0(".Rproj")

  writeLines(
    text =
      'Version: 1.0

RestoreWorkspace: Default
SaveWorkspace: Default
AlwaysSaveHistory: Default

EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8

RnwWeave: Sweave
LaTeX: pdfLaTeX

AutoAppendNewline: Yes
StripTrailingWhitespace: Yes

BuildType: Package
PackageUseDevtools: Yes
PackageInstallArgs: --no-multiarch --with-keep.source
',
    con = file.path(getwd(), proj_name)
  )
}


#' Add package resource to project
#' @param file Character, file to be copied.
#' @param from Character, Internal path to the file.
#' @param to Character, Location that the file should be copied to.
#' @keywords internal
copy_resource <- function(file, from, to) {

  dir_files <- list.files(system.file(from, package = "projectlog"))

  tryCatch(
    file %in% dir_files,
    error = function(e) {
      cli::cli_abort("Could not copy preregistration template to the correct folder.")
    }
  )
  path_to_file <- file.path(system.file(from, package = "projectlog"), file)

  file.copy(
    from = path_to_file,
    to = to
  )
}
