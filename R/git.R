
configure_git <- function() {
  if(!gert::user_is_configured()) {

    cli::cli_alert_warning("user.name and user.email have not been configured yet.")

    name <- readline(prompt = "Type your username here and press enter: " )
    email <- readline(prompt = "Type your email here and press enter: ")

    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
  }
}

#' Log a milestone to git
#'
#' This function can be used to log important milestones to GitHub.
#' For example, you could use this function to commit the final version of
#' a preregistration or to commit a submission to a scientific journal.
#' see \code{\link[OSgit::log_changes]{OSgit::log_changes}} for a very similar function that
#' can be used for more minor commits (i.e., non-milestone changes to your
#' project.)
#'
#' @param ... Character, a vector of files that you want to commit.
#' Use "." to commit all changed files. Use \code{\link[gert::git_status]{gert::git_status()}}
#' to get an overview of all the files that have been changed since the
#' last commit.
#' @param milestone_type Character, A unique identifier for the milestone.
#' Examples could be "preregistration" or "submission". Make sure that the
#' identifiers are the same across similar commits to be able to link them
#' together later on.
#' @param commit_message A message that will be added to your commit to Github.
#' Here, you can give more detailed information about the nature of the changes.
#' @return Nothing. This function is called for its side-effects.
#' @export
log_milestone <- function(..., milestone_type, commit_message) {

  if(!gert::user_is_configured()) {
    gert::git_add(...)
    tryCatch(
      gert::git_commit(paste0("MILESTONE ", milestone_type, commit_message)),
      error = cli::cli_abort("Failed to commit changes.")
    )
    tryCatch(
      gert::git_push(),
      error = cli::cli_abort("Failed to push changes to remote repository.")
    )

    latest_commit <- gert::git_log()$commit[[1]]
    git_url <- gert::git_remote_info()$url |> stringr::str_remove("\\.git") |> paste0("/commit/", latest_commit)

    cli::cli_alert_success("Commit was successful! To see the commit on Github, go to {.url {git_url}}")
  }
}

#' Log changes to git
#'
#' This function can be used to log any changes to files to GitHub.
#' It should be used for any changes that do not constitute major
#' milestones (e.g., timestamping a preregistration). For milestone commits,
#' use \code{\link[OSgit::log_changes]{OSgit::log_changes}}.
#' You can use this function routinely to update the remote Github repository
#' with your latest changes. This way, you make sure that the changes are
#' safely stored remotely.
#' @param ... Character, a vector of files that you want to commit.
#' Use "." to commit all changed files. Use \code{\link[gert::git_status]{gert::git_status()}}
#' to get an overview of all the files that have been changed since the
#' last commit.
#' @param commit_message A message that will be added to your commit to Github.
#' Here, you can give more detailed information about the nature of the changes.
#' @return Nothing. This function is called for its side-effects.
#' @export
log_changes <- function(..., commit_message) {

  if(!gert::user_is_configured()) {
    gert::git_add(...)
    tryCatch(
      gert::git_commit(commit_message),
      error = cli::cli_abort("Failed to commit changes.")
    )
    tryCatch(
      gert::git_push(),
      error = cli::cli_abort("Faied to push changes to remote repository.")
    )

    latest_commit <- gert::git_log()$commit[[1]]
    git_url <- gert::git_remote_info()$url |> stringr::str_remove("\\.git") |> paste0("/commit/", latest_commit)

    cli::cli_alert_success("Commit was successful! To see the commit on Github, go to {.url {git_url}}")
  }
}
