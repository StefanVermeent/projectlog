% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/git_frontend.R
\name{show_tags}
\alias{show_tags}
\title{Show existing milestone tags}
\usage{
show_tags()
}
\value{
A character vector of file names.
}
\description{
This function is a wrapper around `gert::git_tag_list()`
It shows all the tags that were previously used for milestones.
Use this function to make sure that tags of the same type of milestone (e.g., a preregistration) are consistent.
}
