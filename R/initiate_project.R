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
initiate_project <- function(path, project = "single_study", preregistration = "empty", dependencies = "groundhog", git_url = "https://github.com/", ...) {

  dots <- list(...)


  # Create folder structure -------------------------------------------------
  top_folders <- c("manuscript", "supplement", "project_log")
  folders <- c("data", "scripts", "materials", "preregistrations", "analysis_objects")

  if(project == "single_study") {
    purrr::map(top_folders, function(x) {
      dir.create(file.path(path,x), recursive = TRUE)
    })
  }

  if(project == "multistudy") {
    dir.create(file.path(path,"study1"), recursive = TRUE)
    purrr::map(top_folders, function(x) {
      dir.create(file.path(path, x), recursive = TRUE)
    })
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
    tryCatch(
      library(groundhog),
      error = function(e) {
        unlink(path, recursive = TRUE, force = T)
        cli::cli_abort("Could not use the 'groundhog' package as it does not seem to be installed. Try 'install.packages('groundhog')' first.")
      }
    )
    groundhog_script <-
      "
      # Specify the date for which packages need to be installed
      date <- '2023-01-01'
      # Specify names of all required packages
      pkgs <- c('OSgit')

      install.packages('groundhog')

      groundhog.library(pkgs, date = date)
    "
    writeLines(groundhog_script, con = file.path(path,"dependencies.R"))
  }

  if(dependencies == "renv") {

    tryCatch(
      library(renv),
      error = function(e) {
        unlink(path, recursive = TRUE, force = T)
        cli::cli_abort("Could not use the 'renv' package as it does not seem to be installed. Try 'install.packages('renv')' first.")
      }
    )
    renv::init()
  }

  writeLines(readme, con = file.path(path,"README.Rmd"))


  # Write preregistration ---------------------------------------------------
  cli::cli_h1("Add necessary files")

  add_preregistration(path, preregistration)

  # TODO: Preregistration
  # TODO: Registered report
  # TODO: README

  # Create R Markdown file
  rmarkdown::draft(
    "my_preregistration.Rmd"
    , "cos_prereg"
    , package = "prereg"
    , create_dir = FALSE
    , edit = FALSE
  )

  # Render file
  rmarkdown::render("my_preregistration.Rmd")



  # Link Git ----------------------------------------------------------------

  # Check if valid Git signature exists
  cli::cli_h1("Configuring Git")
  use_git <- has_git()
  if(!use_git){
    unlink(path, recursive = TRUE, force = T)
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
      unlink(path, recursive = TRUE, force = T)
      cli::cli_abort("Failed to create first commit of the project.")
    })
  }

  cli::cli_alert_success("First commit was created succesfully.")



# Connect to remote repository --------------------------------------------

  cli::cli_h1("Connect to remote repository")

  valid_repo <- is_valid_url(url = git_url)

  if(!valid_repo) {
    cli::cli_abort("{git_url} is not a valid ")
  }

  cli::cli_alert_info("Trying with url '{git_url}'")

  if(use_git & valid_repo){

    tryCatch(
      gert::git_remote_add(url = git_url, name = "origin", repo = path),

      error = function(e) {
        unlink(path, recursive = TRUE, force = T)
        cli::cli_abort("Failed to connect to the remote Github repository that you specified.")
      }
    )
    cli::cli_alert_success("Succesfully connected to remote repository!")
  }

  cli::cli_alert_info("Opening your new project...")
}


