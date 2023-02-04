#' Initiate your project folder
#'
#' This function creates your project folder.
#'
#' @param path Character, the directory in which the project is initiated.
#' @param project Character, the type of project that will be initiated.
#' Options include 'single_study' for a project consisting of a single study,
#' 'multistudy' for a project consisting of multiple studies, and
#' 'registered_report' for a project containing a Registered Report.
#' Default: 'single_study'.
#' @param dependencies Character, indicates whether and how you want to keep track
#' of package dependencies. Options include \code{\link[renv]{init}},
#' \code{\link[groundhog]{groundhog}}, or 'none'.
#' @param ... Additional arguments passed to and from functions.
#' @return The initial set-up of your project folder.
#' @export
initiate_project <- function(path, project = "single_study", dependencies = "groundhog", ...) {

  dots <- list(...)

  folders <- c("data", "scripts", "preregistrations", "manuscript", "supplement", "analysis_objects")

  if(project == "single_study") {
    purrr::map(folders, function(x) {
      dir.create(file.path(path,x), recursive = TRUE)
    })
  }

  if(project == "multistudy") {
    purrr::map(folders, function(x) {
      dir.create(file.path(path,"study1", x), recursive = TRUE)
    })
  }

  if(project == "registered_report") {
    purrr::map(folders, function(x) {
      dir.create(file.path(path,x), recursive = TRUE)
    })
    dir.create("registered_report")
  }

  readme <- "### Placeholder"

  writeLines(readme, con = file.path(path,"README.Rmd"))

}


