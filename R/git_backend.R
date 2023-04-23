#' Configure Git name and email if necessary
#' @keywords internal
configure_git <- function() {
  if(!gert::user_is_configured()) {
    cli::cli_alert_warning("user.name and user.email have not been configured yet.")
    name <- readline(prompt = "Type your username here and press enter: " )
    email <- readline(prompt = "Type your email here and press enter: ")
    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
  }
}

#' Check if Git user name and email are configured
#' @keywords internal
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

#' Check if Git is configured
#' @keywords internal
has_git <- function(){
  tryCatch({
    config <- gert::libgit2_config()
    return(has_git_user() & (any(unlist(config[c("ssh", "https")]))))
  }, error = function(e){
    return(FALSE)
  })
}
