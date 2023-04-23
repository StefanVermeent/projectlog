configure_git <- function() {
  if(!gert::user_is_configured()) {
    cli::cli_alert_warning("user.name and user.email have not been configured yet.")
    name <- readline(prompt = "Type your username here and press enter: " )
    email <- readline(prompt = "Type your email here and press enter: ")
    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
  }
}


has_git <- function(){
  tryCatch({
    config <- gert::libgit2_config()
    return(has_git_user() & (any(unlist(config[c("ssh", "https")]))))
  }, error = function(e){
    return(FALSE)
  })
}


is_valid_url <- function(url) {

  valid_url <- regexpr(text = git_url, pattern = "((git|ssh|http(s)?)|(git@[\\w\\.]+))(:(//)?)([\\w\\.@\\:/\\-~]+)(\\.git)(/)?")
  url_exists <- RCurl::url.exists(git_url)

  if(valid_url & url_exists) {
    TRUE
  } else FALSE
}
