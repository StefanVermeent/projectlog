
configure_git <- function() {
  if(!gert::user_is_configured()) {

    cli::cli_alert_warning("user.name and user.email have not been configured yet.")

    name <- readline(prompt = "Type your username here and press enter: " )
    email <- readline(prompt = "Type your email here and press enter: ")

    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
  }
}


log_milestone <- function(..., milestone_type, commit_message) {

  if(!gert::user_is_configured()) {
    gert::git_add(...)
    tryCatch(
      gert::git_commit(paste0("MILESTONE ", milestone_type, commit_message)),
      error = cli::cli_abort("Failed to commit changes.")
    )
    tryCatch(
      gert::git_push(),
      error = cli::cli_abort("Faied to push changes to remote repository.")
    )
  }
}
