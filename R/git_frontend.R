#' Show untracked project changes
#'
#' This function is a wrapper around 'gert::git_status())'.
#' It shows all the files that have changed since the last commit to GitHub.
#' It is recommended to routinely commit untracked changes to GitHub using
#' the 'log_changes()' or 'log_milestone()' functions.
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
#' @return A character vector of file names.
#' @export
show_tags <- function() {

  tags <- gert::git_tag_list()
  if(nrow(tags == 0)) {
    return(cli::cli_alert_info("No existing tags were found. It seems like you haven't logged any milestones yet."))
  } else{
    tags |>
      dplyr::select(names)

  }
}
