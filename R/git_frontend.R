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

  invisible(status$file)
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
