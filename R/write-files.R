add_readme <- function(path) {


}


add_preregistration <- function(path, template) {

  prereg_path <- grep(x = list.dirs(path = path), pattern = "preregistrations", value = T)
  if(!template %in% c("empty", "secondary")) {
    rmarkdown::draft(
      file = file.path(prereg_path, "preregistration.Rmd"),
      template = paste0(template, "_prereg"),
      package = "prereg",
      edit = FALSE
    )
  } else {
    if(template == "empty") {
      file.copy(
        from = "inst/rstudio/templates/project/resources/prereg_empty.Rmd",
        to = file.path(prereg_path, "preregistration.Rmd")
      )
    }

    if(template == "secondary") {
      file.copy(
        from = "inst/rstudio/templates/project/resources/secondary.Rmd",
        to = file.path(prereg_path, "preregistration.Rmd")
      )
    }
  }
}

add_registered_report <- function(path) {


}

add_manuscript <- function(path) {

}
