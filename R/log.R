#' Log a milestone to git
#'
#' This function can be used to log important milestones to GitHub that are
#' not covered by any of the log_milestone.
#' For example, you could use this function to commit the final version of
#' a preregistration or to commit a submission to a scientific journal.
#' see `projectlog::log_changes` for a very similar function that
#' can be used for more minor commits (i.e., non-milestone changes to your
#' project.)
#' @param files A vector of files that you want to commit.
#' Use "." to commit all changed files. Use `gert::git_status`
#' to get an overview of all the files that have been changed since the
#' last commit.
#' @param commit_message A message that will be added to your commit to Github.
#' Here, you can give more detailed information about the nature of the changes.
#' @param tag Character, A unique identifier for the milestone.
#' Examples could be "preregistration" or "submission". Make sure that the
#' identifiers are the same across similar commits to be able to link them
#' together later on. Spaces and trailing numbers are not allowed.
#' Preferably use a single word or link multiple words (e.g., 'submission_to_journal').
#' @return Nothing. This function is called for its side-effects.
#' @export
log_milestone <- function(files, commit_message, tag) {
  if(gert::user_is_configured()) {
    validate_files(files)
    validate_tag(tag)
    matching_tags <- count_matching_tags(tag)

    cli::cli_h1("Searching for existing project milestones")
    cli::cli_alert_info("The following existing milestone tags were found:")
    cli::cli_ul(cli::col_blue(gert::git_tag_list()$name |> gsub(pattern = "[0-9]*$", replacement = "") |> unique()))

    if(matching_tags > 0) {
      tag <- paste0(tag,matching_tags)
    } else {
      if(!usethis::ui_yeah(paste0("You have not used the tag '", cli::col_blue(tag), "' before. Are you sure you want to continue?"))) {
        return(cli::cli_alert_info("No changes were committed."))
      }
    }

    gert::git_add(files)

    commit_hash <- validate_commit(commit_message)
    gert::git_tag_create(name = tag, message = '', ref = commit_hash, repo = '.')
    gert::git_tag_push(name = tag, repo = ".")
    gert::git_push()

    cli::cli_bullets(c(
      "v" = "Logging was successful!",
      "v" = paste("Milestone tag",cli::col_blue(tag),"was succesfully created."),
      "i" = paste0("Go to {.url {'", file.path(gert::git_remote_list()$url |> gsub(x = _, pattern = "\\.git$", replacement = ""), "commit", commit_hash,"'}}"))
    ))
  } else {
    cli::cli_abort("Git user is not configured!")
  }
}

#' Log changes to git
#'
#' This function can be used to log any changes to files to GitHub.
#' It should be used for any changes that do not constitute major
#' milestones, such as regular code updates. For milestone commits,
#' use `projectlog::log_milestones`.
#' You can use this function routinely to update the remote Github repository
#' with your latest changes. This way, you make sure that the changes are
#' safely stored remotely.
#' @param files A vector of files that you want to commit.
#' Use "." to commit all changed files. Use `gert::git_status`
#' to get an overview of all the files that have been changed since the
#' last commit.
#' @param commit_message A message that will be added to your commit to Github.
#' Here, you can give more detailed information about the nature of the changes.
#' @return Nothing. This function is called for its side-effects.
#' @export
log_changes <- function(files = ".", commit_message) {

  if(gert::user_is_configured()) {
    validate_files(files)
    gert::git_add(files)
    commit <- gert::git_commit(commit_message)
    gert::git_push()

    git_url <- gert::git_remote_info()$url |> stringr::str_remove("\\.git") |> paste0("/commit/", commit)

    cli::cli_alert_success("Logging was successful! To see the commit on Github, go to {.url {git_url}}")
  } else {
    cli::cli_abort("Git user is not configured!")
  }
}

#' Count number of existing tags on GitHub that match the currently supplied tag.
#' @param tag Character, the tag that should be given to the milestone commit.
#' @keywords internal
count_matching_tags <- function(tag) {
  gert::git_tag_list()$name |>
    gsub(pattern = "[0-9]*$", replacement = "") |>
    grepl(pattern = tag) |>
    sum()
}

#' Check whether files to be logged are valid.
#' @param files Vector of files to be logged.
#' @keywords internal
validate_files <- function(files) {
  if(nrow(gert::git_status()) == 0) {
    cli::cli_abort("There are no files with changes to log.")
  }

  if(files == ".") {
    return(invisible(TRUE))
  }

  if(any(!file.exists(files))) {
    error_files <- files[!file.exists(files)]
    cli::cli_abort("Could not find the following specified file{?s} in your project: {error_files}")
    return(invisible(FALSE))
  } else {
    invisible(TRUE)
  }
}

#' Check whether supplied tag is valid
#' @param tag Character, a tag to be used in the milestone commit.
#' @keywords internal
validate_tag <- function(tag) {
  TRUE
  #TODO
}

#' Check whether milestone can be committed to GitHub.
#' @param commit_message Character, message for the milestone commit.
#' @keywords internal
validate_commit <- function(commit_message) {
  tryCatch(
  commit <- gert::git_commit(commit_message),
  error = function(e) {
    gert::git_reset_mixed()
    cli::cli_abort("Failed to commit your changes locally. Reverting changes...")
  })
}
