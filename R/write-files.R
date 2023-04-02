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

  rr_path <- grep(x = list.dirs(path = path), pattern = "registered_report", value = T)

  file.copy(
    from = "inst/rstudio/templates/project/resources/registered_report.Rmd",
    to = file.path(rr_path, "registered_report.Rmd")
  )


}

add_manuscript <- function(path) {

}

add_rproj <- function(path) {

  proj_name <-
    regexpr(pattern = "([a-z]|[0-9]|-|_)*$", text = path) |>
    regmatches(m = _, x = path) |>
    paste0(".Rproj")

  writeLines(
    text =
      'Version: 1.0

RestoreWorkspace: Default
SaveWorkspace: Default
AlwaysSaveHistory: Default

EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8

RnwWeave: Sweave
LaTeX: pdfLaTeX

AutoAppendNewline: Yes
StripTrailingWhitespace: Yes

BuildType: Package
PackageUseDevtools: Yes
PackageInstallArgs: --no-multiarch --with-keep.source
',
    con = file.path(getwd(), proj_name)
  )
}
