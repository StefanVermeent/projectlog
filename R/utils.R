#' Parse project name
#' @param path Path to project
#' @keywords internal
get_project_name <- function(path){
  regexpr(pattern = "([a-z]|[0-9]|-|_)*$", text = path) |>
  regmatches(m = _, x = path)
}

#' Get Git URL
#' @keywords internal
get_git_url <- function() {
  gert::git_remote_list()$url |>
    gsub(x = _, pattern = "\\.git$", replacement = "")
}
