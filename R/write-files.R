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
    }
  }
}

add_registered_report <- function(path) {


}

add_manuscript <- function(path) {

}
