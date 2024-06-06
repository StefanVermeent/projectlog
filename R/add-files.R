#' Add top-level project README file to project
#'
#' If you did not initiate your project using `projectlog::initiate_project()`, you can use this function to generate a README file that will be placed at the highest level of your repository.
#' It will include example text for a description of your project, an overview of the (most important) folders, and code to generate an overview of your project milestones.
#' @param path Character, path to project repository.
#' @return A README.Rmd file at the highest level of your repository
#' @export
add_project_readme <- function(path = getwd()){

  if(file.exists(file.path(path, "README.Rmd"))) {
    cli::cli_abort("Your repository already contains a top-level README.Rmd file. If you want to generate a new README file, please remove the old file first.")
  }

  link <- paste0(get_git_url(), "/tree/master/")
  writeLines(
    paste0("---
title: '[Your title here]'
output:
  html_document:
    keep_md: true
bibliography: bib-files/references.bib
csl: bib-files/apa.csl
link-citations: true
---

*Last updated `r format(Sys.time(), 'on %A, %B %d, %Y at %I:%M %p')`*

## Overview

This repository contains a preregistration, data, code, an (eventual) reproducible manuscript/supplement for a project entitled '[Your title here]'.

[Brief description of your project here].

## Directory Structure

The names of each folder are intended to be self-explanatory. There are six components organize the inputs and outputs of this project:

1.  [`codebooks`](", link, "codebooks): lists of variable names, labels, and value labels (where applicable).
2.  [`data`](", link, "data): raw data, stored as `.Rdata` and .csv files.
3.  [`manuscript`](", link, "manuscript): a reproducible manuscript for submission to a journal.
4.  [`preregistration`](", link, "preregistration): a preregistration document that details the plans for this project.
5.  [`scripts`](", link, "scripts): R-scripts that read, analyze, and produce all outputs.
6.  [`supplement`](", link, "supplement): a supplemental text with additional information and materials.

# Project History

Below is an overview of all the major milestones of this project, including a description and links.
The links take you to the historic version of the project that corresponds to the milestone.

```{r results ='asis', echo = FALSE}

projectlog::generate_milestone_overview()

```

## References

           "
    ),
    con = file.path(getwd(), "README.Rmd"))

  tryCatch(
    {
      rmarkdown::render(input = file.path(getwd(), "README.Rmd"), output_dir = file.path(getwd()), quiet = TRUE)
      file.remove(file.path(path, "README.html"))
    },
    error = function(e){
      cli::cli_alert_warning("{cli::col_blue('README.Rmd')} could not be rendered.")
    }
  )
}

#' Add manuscript folder README file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_manuscript_readme <- function(path){
  README <- writeLines(
    paste0(
    "---
bibliography: ../bib-files/references.bib
csl: ../apa.csl
format:
  docx:
    reference-doc: reference-doc.docx
    toc: true
    toc-location: left
    toc-title: Table of Contents
output:
  officedown::rdocx_document:
    page_margins:
      bottom: 1
      footer: 0
      gutter: 0
      header: 0.5
      left: 1
      right: 1
      top: 1
    plots:
      align: center
      caption:
        pre: 'Figure '
        sep: '. '
        style: Image Caption
    tables:
      caption:
        pre: 'Table '
        sep: '. '
        style: Table Caption
  pdf_document: default
  word_document: default
editor:
  markdown:
    wrap: sentence
---

This is the main manuscript.

## References
  "
    ),
    con = file.path(path,"README.Rmd")
  )
}

#' Add preregistration file to project
#' @param path Character, path to project repository.
#' @param template Character, preregistration template to be used.
#' @keywords internal
add_preregistration_readme <- function(path, template){
  prereg_path <- grep(x = list.dirs(path = path), pattern = "preregistration", value = T)

    if(template == "empty") {
      copy_resource(file = "prereg_empty.Rmd", from = "rmd", to = prereg_path)
      file.rename(from = file.path(prereg_path, "prereg_empty.Rmd"), to = file.path(prereg_path, "README.Rmd"))
    }
    if(template == "aspredicted") {
      copy_resource(file = "prereg_aspredicted.Rmd", from = "rmd", to = prereg_path)
      file.rename(from = file.path(prereg_path, "prereg_aspredicted.Rmd"), to = file.path(prereg_path, "README.Rmd"))
    }
    if(template == "secondary") {
      copy_resource(file = "prereg_secondary.Rmd", from = "rmd", to = prereg_path)
      file.rename(from = file.path(prereg_path, "prereg_secondary.Rmd"), to = file.path(prereg_path, "README.Rmd"))
    }
  }


#' Add scripts folder README file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_scripts_readme <- function(path){
  README <- writeLines(
    paste0(
    "---
title: 'Analysis scripts'
output: github_document
bibliography: ../bib-files/references.bib
csl: ../apa.csl
link-citations: true
---"
    ),
    con = file.path(path,"README.Rmd")
  )
}

#' Add supplemental materials file
#' @param path Character, path to project repository.
#' @keywords internal
add_supplement_readme <- function(path){
  README <- writeLines(
    paste0(
    "
---
bibliography: ../bib-files/references.bib
csl: ../apa.csl
format:
  docx:
    reference-doc: reference-doc.docx
    toc: true
    toc-location: left
    toc-title: Table of Contents
output:
  officedown::rdocx_document:
    page_margins:
      bottom: 1
      footer: 0
      gutter: 0
      header: 0.5
      left: 1
      right: 1
      top: 1
    plots:
      align: center
      caption:
        pre: 'Figure '
        sep: '. '
        style: Image Caption
    tables:
      caption:
        pre: 'Table '
        sep: '. '
        style: Table Caption
  pdf_document: default
  word_document: default
editor:
  markdown:
    wrap: sentence
---

These are the supplemental materials.

## References
  "
    ),
    con = file.path(path,"README.Rmd")
  )
}

#' Add materials folder README file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_materials_readme <- function(path){
  README <- writeLines(
    paste0(
      "---
title: 'Materials'
output: github_document
bibliography: bib-files/references.bib
csl: bib-files/apa.csl
link-citations: true
---"
    ),
    con = file.path(path,"README.Rmd")
  )
}



#' Add .Rproj file to project
#' @param path Character, path to project repository.
#' @keywords internal
add_rproj <- function(path) {

  proj_name <-
    get_project_name(path) |>
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


#' Add package resource to project
#' @param file Character, file to be copied.
#' @param from Character, Internal path to the file.
#' @param to Character, Location that the file should be copied to.
#' @keywords internal
copy_resource <- function(file, from, to) {

  dir_files <- list.files(system.file(from, package = "projectlog"))

  tryCatch(
    file %in% dir_files,
    error = function(e) {
      cli::cli_abort("Error copying file from projectlog.")
    }
  )
  path_to_file <- file.path(system.file(from, package = "projectlog"), file)

  file.copy(
    from = path_to_file,
    to = to
  )
}

