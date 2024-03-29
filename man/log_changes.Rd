% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/log.R
\name{log_changes}
\alias{log_changes}
\title{Log changes to git}
\usage{
log_changes(files = ".", commit_message)
}
\arguments{
\item{files}{A vector of files that you want to commit.
Use "." to commit all changed files. Use `gert::git_status`
to get an overview of all the files that have been changed since the
last commit.}

\item{commit_message}{A message that will be added to your commit to Github.
Here, you can give more detailed information about the nature of the changes.}
}
\value{
Nothing. This function is called for its side-effects.
}
\description{
This function can be used to log any changes to files to GitHub.
It should be used for any changes that do not constitute major
milestones, such as regular code updates. For milestone commits,
use `projectlog::log_milestones`.
You can use this function routinely to update the remote Github repository
with your latest changes. This way, you make sure that the changes are
safely stored remotely.
}
