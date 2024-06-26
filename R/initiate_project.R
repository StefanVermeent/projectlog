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
#' of package dependencies. Options include "renv",
#' "groundhog", or "none".
#' Default: 'groundhog'
#' @param preregistration TBD
#' @param create_github Character, should a remote repository be created on GitHub?
#' If 'yes', a remote repository is created with the same name as the local project,
#' and all current changes are pushed to this remote repository. If 'no', git is
#' only set up locally.
#' Default: 'yes'
#' @param private_repo Logical, Should the created GitHub repository be private or public?
#' Default: 'yes'
#' @param ... Additional arguments passed to and from functions.
#' @return The initial set-up of your project repository.
#' @export
initiate_project <- function(path, project = "single_study", preregistration = "empty", dependencies = "groundhog", create_github = TRUE, private_repo = TRUE, ...) {

  dots <- list(...)

  if(dir.exists(path)){
    cli::cli_abort("This directory already exists!")
  }

  cli::cli_h1("Create project folder structure")



  if(project == "single_study") {
    c("codebooks", "data", "manuscript", "preregistration", "scripts", "supplement", "materials", "bib-files") |>
      lapply(function(x){
        dir.create(file.path(path, x), recursive = TRUE)
      })
    copy_resource(file = "references.bib", from = "rmd", to = file.path(path, "bib-files", "references.bib"))
    copy_resource(file = "apa.csl", from = "rmd", to = file.path(path, "apa.csl"))
    copy_resource(file = "reference-doc.docx", from = "rmd", to = file.path(path, "manuscript/reference-doc.docx"))
    copy_resource(file = "reference-doc.docx", from = "rmd", to = file.path(path, "supplement/reference-doc.docx"))
    add_manuscript_readme(path = file.path(path, "manuscript"))
    add_preregistration_readme(path = file.path(path, "preregistration"), template = preregistration)
    add_scripts_readme(path = file.path(path, "scripts"))
    add_supplement_readme(path = file.path(path, "supplement"))
    add_materials_readme(path = file.path(path, "materials"))
  }

  if(project == "multistudy") {
    c("manuscript", "supplement", "study1", "bib-files") |>
      lapply(function(x){
        dir.create(file.path(path, x), recursive = TRUE)
      })
    c("codebooks", "data", "preregistration", "scripts", "materials") |>
      lapply(function(x){
        dir.create(file.path(path, "study1", x))
      })
    copy_resource(file = "references.bib", from = "rmd", to = file.path(path, "bib-files", "references.bib"))
    copy_resource(file = "apa.csl", from = "rmd", to = file.path(path, "apa.csl"))
    copy_resource(file = "reference-doc.docx", from = "rmd", to = file.path(path, "manuscript", "reference-doc.docx"))
    copy_resource(file = "reference-doc.docx", from = "rmd", to = file.path(path, "supplement", "reference-doc.docx"))
    add_manuscript_readme(path = file.path(path, "manuscript"))
    add_preregistration_readme(path = file.path(path, "study1", "preregistration"), template = preregistration)
    add_scripts_readme(path = file.path(path, "study1", "scripts"))
    add_supplement_readme(path = file.path(path, "supplement"))
    add_materials_readme(path = file.path(path, "study1", "materials"))
  }

  dir.create(file.path(path, ".projectlog"))
  writeLines("", con = file.path(path,".projectlog/MD5"))

  cli::cli_alert_success("All folders and related files were successfully created. The directory looks as follows:")
  fs::dir_tree(path)

  # Write necessary files ---------------------------------------------------

  if(dependencies != "none"){

    cli::cli_h1("Setting up project dependency management")

    if(dependencies == "groundhog") {
      tryCatch(
        'groundhog'  %in% .packages(TRUE),
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
      pkgs <- c('projectlog')

      # install.packages('groundhog')

      groundhog::groundhog.library(pkgs, date = date)
    "
      writeLines(groundhog_script, con = file.path(path,"dependencies.R"))
      cli::cli_alert_success("Initiated `groundhog` for managing package dependencies ('dependencies.R'). See {.url https://groundhogr.com/} for more information.")
    }

    if(dependencies == "renv") {
      tryCatch(
        'renv'  %in% .packages(TRUE),
        error = function(e) {
          unlink(path, recursive = TRUE, force = T)
          cli::cli_abort("Could not use the 'renv' package as it does not seem to be installed. Try 'install.packages('renv')' first.")
        }
      )
      renv::init()
      cli::cli_alert_success("Initiated `renv` for managing package dependencies. See {.url https://rstudio.github.io/renv/articles/renv.html} for more information.")
    }
  }

  # Link Git ----------------------------------------------------------------

  # Check if valid Git signature exists
  cli::cli_h1("Configure Git")
  use_git <- has_git()
  if(!use_git){
    unlink(path, recursive = TRUE, force = T)
    cli::cli_abort("Could not find a working installation of 'Git'")

  } else {
    cli::cli_alert_success("Working version of Git found!")
    gert::git_init(path = path)
  }
  cli::cli_alert_success("Local Git configuration was succesful.")

  # Switch to new project and manually create an .Rproj file
  setwd(path)
  add_rproj(path)

  # Create local git repository
  wrap_use_git(message = "Initial commit")

  # Create remote git repository
  if(create_github == TRUE) {
    wrap_use_github(
      private = private_repo,
      protocol = 'https'
    )
  }

  add_project_readme(path = path)
  if(file.exists('README.md')){
    log_changes(c('README.Rmd', "README.md"), commit_message = "Add project README file")
  } else {
    log_changes(c('README.Rmd'), commit_message = "Add project README file")
  }

  cli::cli_alert_success("All set! Switching now to your new project at {cli::col_blue(getwd())}")
}


#' Wrapper around `usethis::use_git`.
#' @keywords internal
wrap_use_git <- function(...){
  usethis::use_git(...)
}

#' Wrapper around `usethis::use_github`.
#' @keywords internal
wrap_use_github <- function(...){
  usethis::use_github(...)
}


#' Create a remote project repository on GitHub
#'
#' Creates a remote repository on GitHub if you had not already done so when
#' initiating the project. It automatically creates the repository for you
#' and pushes all the changes and milestones that you have logged so far.
#'
#' @param private_repo Logical, should the GitHub repository be private or
#' public?
#' Default is TRUE
#' @return Nothing, this function is called for it's side-effects.
#' @export
create_github_repo <- function(private_repo = TRUE){
  wrap_use_github(
    private = private_repo,
    protocol = 'https'
  )

}
