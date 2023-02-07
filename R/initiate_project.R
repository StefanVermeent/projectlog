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
#' @param git_url Character, url of your remote git repository.
#' @param ... Additional arguments passed to and from functions.
#' @return The initial set-up of your project folder.
#' @export
initiate_project <- function(path, project = "single_study", dependencies = "groundhog", git_url, ...) {

  dots <- list(...)


  # Create folder structure -------------------------------------------------
  folders <- c("data", "scripts", "preregistrations", "manuscript", "supplement", "analysis_objects", "project_log")

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

  writeLines("", con = "project_log/MD5")

  readme <- "### Placeholder"


  # Manage package dependencies ---------------------------------------------
  if(dependencies == "groundhog") {

    groundhog_script <-
      "
      # Specify the date for which packages need to be installed
      date <- '2023-01-01'
      # Specify names of all required packages
      pkgs <- c('OSgit')

      install.packages('groundhog)

      groundhog.library(pkgs, date = date)
    "
    writeLines(groundhog_script, con = file.path(path,"dependencies.R"))
  }

  if(dependencies == "renv") {

    # TODO
  }

  writeLines(readme, con = file.path(path,"README.Rmd"))


  # Write files -------------------------------------------------------------

  # TODO: Preregistration
  # TODO: Registered report
  # TODO: README


  # Link Git ----------------------------------------------------------------

  # Configure user.name and user.email if necessary
  cli::cli_h1("Configure Git")
  configure_git()
  cli::cli_alert_success("Git was configured successfully")

  # Create local repo
  cli::cli_h1("Connect to remote repository")
  gert::git_remote_add(url = git_url)

}


