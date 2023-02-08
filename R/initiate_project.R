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
initiate_project <- function(path, project = "single_study", dependencies = "groundhog", git_url = "https://github.com/", ...) {

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
    dir.create(file.path(path,"registered_report"))
  }

  writeLines("", con = file.path(path,"project_log/MD5"))

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

    tryCatch(
      library(renv),
      error = cli::cli_abort("Package 'renv' not found. Try 'install.packages('renv')' first.")
    )
  }

  writeLines(readme, con = file.path(path,"README.Rmd"))


  # Write files -------------------------------------------------------------

  # TODO: Preregistration
  # TODO: Registered report
  # TODO: README


  # Link Git ----------------------------------------------------------------

  # Check if valid Git signature exists
  cli::cli_h1("Configuring Git")
  use_git <- has_git()
  if(!use_git){
    cli::cli_abort("Could not find a working installation of 'Git'")
  } else {
    cli::cli_alert_info("Working version of Git found!")
    gert::git_init(path = path)
  }
  cli::cli_alert_success("Git was configured successfully.")


  # Create first commit
  if(use_git){
    tryCatch({
      gert::git_add(files = ".", repo = path)
      gert::git_commit(message = "Initial commit", repo = path)
      cli::cli_alert_info("Creating first commit of the project.")
    }, error = function(e){
      cli::cli_abort("Failed to create first commit of the project.")
    })
  }

  cli::cli_alert_success("First commit was created succesfully.")



# Connect to remote repository --------------------------------------------

  cli::cli_h1("Connect to remote repository")
  # TODO: validate git url
  valid_repo = TRUE

  if(use_git & valid_repo) {

  }

  cli::cli_alert_info("Trying with url '{git_url}'")

  if(use_git & valid_repo){

    tryCatch(
      gert::git_remote_add(url = git_url, name = "origin", repo = path),

      error = function(e) {
        cli::cli_abort("Failed to connect to the remote Github repository that you specified. (the temp message)")
      }
    )
    cli::cli_alert_success("Succesfully connected to remote repository!")
  }
}


