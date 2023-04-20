
configure_git <- function() {
  if(!gert::user_is_configured()) {

    cli::cli_alert_warning("user.name and user.email have not been configured yet.")

    name <- readline(prompt = "Type your username here and press enter: " )
    email <- readline(prompt = "Type your email here and press enter: ")

    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
  }
}

#' @title Check whether global 'Git' credentials exist
#' @description Check whether the values \code{user.name} and \code{user.email}
#' exist exist in the 'Git' global configuration settings.
#' Uses \code{\link[gert:git_config]{git_config_global}}.
#' @return Logical, indicating whether 'Git' global configuration settings could
#' be retrieved, and contained the values
#' \code{user.name} and \code{user.email}.
#' @rdname has_git_user
#' @examples
#' has_git_user()
#' @export
#' @importFrom gert git_config_global
has_git_user <- function(){
  tryCatch({
    cf <- gert::git_config_global()
    if(!("user.name" %in% cf$name) & ("user.email" %in% cf$name)){
      stop()
    } else {
      return(TRUE)
    }
  }, error = function(e){
    message("No 'Git' credentials found, returning name = 'yourname' and email = 'yourname@email.com'.")
    return(FALSE)
  })
}

#' @importFrom gert libgit2_config git_config_global
has_git <- function(){
  tryCatch({
    config <- gert::libgit2_config()
    return(has_git_user() & (any(unlist(config[c("ssh", "https")]))))
  }, error = function(e){
    return(FALSE)
  })
}

#' Log a milestone to git
#'
#' This function can be used to log important milestones to GitHub that are
#' not covered by any of the log_milestone.
#' For example, you could use this function to commit the final version of
#' a preregistration or to commit a submission to a scientific journal.
#' see \code{\link[projectlog::log_changes]{projectlog::log_changes}} for a very similar function that
#' can be used for more minor commits (i.e., non-milestone changes to your
#' project.)
#' @param ... Character, a vector of files that you want to commit.
#' Use "." to commit all changed files. Use \code{\link[gert::git_status]{gert::git_status()}}
#' to get an overview of all the files that have been changed since the
#' last commit.
#' @param milestone_type Character, A unique identifier for the milestone.
#' Examples could be "preregistration" or "submission". Make sure that the
#' identifiers are the same across similar commits to be able to link them
#' together later on. Spaces are not allowed. Preferably use a single word
#' or link multiple words (e.g., 'submission_to_journal').
#' @param commit_message A message that will be added to your commit to Github.
#' Here, you can give more detailed information about the nature of the changes.
#' @return Nothing. This function is called for its side-effects.
#' @export
log_milestone <- function(..., commit_message, tag) {
  if(gert::user_is_configured()) {
    validate_files(...)
    validate_tag(tag)
    gert::git_add(...)
    commit_tag_push(tag = tag, commit_message = commit_message)
  }

}

#' Log changes to git
#'
#' This function can be used to log any changes to files to GitHub.
#' It should be used for any changes that do not constitute major
#' milestones, such as regular code updates. For milestone commits,
#' use \code{\link[projectlog::log_changes]{projectlog::log_changes}}.
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
log_changes <- function(files = ".", commit_message) {

  if(gert::user_is_configured()) {
    validate_files(files)
    gert::git_add(files)
    commit_push(commit_message = paste(commit_message))

    latest_commit <- gert::git_log()$commit[[1]]
    git_url <- gert::git_remote_info()$url |> stringr::str_remove("\\.git") |> paste0("/commit/", latest_commit)

    cli::cli_alert_success("Commit was successful! To see the commit on Github, go to {.url {git_url}}")
  } else {
    cli::cli_abort("Git user is not configured!")
  }
}

#' Show untracked project changes
#'
#' This function is a wrapper around 'gert::git_status())'.
#' It shows all the files that have changed since the last commit to GitHub.
#' It is recommended to routinely commit untracked changes to GitHub using
#' the 'log_changes()' or 'log_milestone()' functions.
#'
#' @return A character vector of file names.
#' @export
show_changes <- function() {
  status <- gert::git_status()
  cli::cli_alert_info("The following files have changed since your last commit:")
  print(status)

  return(invisible(status$file))
}

is_valid_url <- function(url) {

  valid_url <- regexpr(text = git_url, pattern = "((git|ssh|http(s)?)|(git@[\\w\\.]+))(:(//)?)([\\w\\.@\\:/\\-~]+)(\\.git)(/)?")
  url_exists <- RCurl::url.exists(git_url)

  if(valid_url & url_exists) {
    TRUE
  } else FALSE
}


commit_push <- function(commit_message) {

  tryCatch(
    commit <- gert::git_commit(commit_message),
    error = function(e) {
      cli::cli_abort("Failed to commit changes.")
    }
  )

  git_tag_create(name = )

  tryCatch(
    gert::git_push(),
    error = function(e) {
      cli::cli_abort("Failed to push changes to remote repository.")
    }
  )

  tryCatch(
    gert::git_tag(),
    error = function(e) {
      cli::cli_abort("Failed to push changes to remote repository.")
    }
  )
}


commit_tag_push <- function(tag, commit_message) {

  matching_tags <- gert::git_tag_list()$name |>
    gsub(pattern = "[0-9]*$", replacement = "") |>
    grepl(pattern = tag) |>
    sum()

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

  tryCatch(
    {
    commit <- gert::git_commit(commit_message)
    gert::git_tag_create(name = tag, message = '', ref = commit, repo = '.')
    gert::git_tag_push(name = tag, repo = ".")
    },
    error = function(e) {
      cli::cli_abort("Failed to commit and/or tag changes.")
    }
  )

  tryCatch(
    gert::git_push(),
    error = function(e) {
      cli::cli_abort("Failed to push changes to remote repository.")
    }
  )

  cli::cli_bullets(c(
    "v" = "All changes were pushed to the remote repository.",
    "v" = paste("Tag",cli::col_blue(tag),"was succesfully created."),
    "i" = paste0("Go to", gert::git_remote_list()$url |> gsub(x = _, pattern = "\\.git$", replacement = ""), "/commit/", commit)
  ))
}

#' Show existing milestone tags
#'
#' This function is a wrapper around `gert::git_tag_list()`
#' It shows all the tags that were previously used for milestones.
#' Use this function to make sure that tags of the same type of milestone (e.g., a preregistration) are consistent.
#'
#' @return A character vector of file names.
#' @export
existing_tags <- function() {

  tags <- gert::git_tag_list()
  if(nrow(tags == 0)) {
    return(cli::cli_alert_info("No existing tags were found. It seems like you haven't logged any milestones yet."))
  } else{
    tags |>
      dplyr::select(names)

  }
}

