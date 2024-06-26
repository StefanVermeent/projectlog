% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read-functions.R
\name{construct_code}
\alias{construct_code}
\title{Construct code that is used to read new data}
\usage{
construct_code(
  file,
  col_select,
  read_fun,
  row_filter,
  row_shuffle,
  long_format,
  seed,
  dots_chr
)
}
\arguments{
\item{col_select}{Columns to include in the results. You can use the same
mini-language as `dplyr::select()` to refer to the columns by name. Use `c()`
to use more than one selection expression. Although this usage is less common,
col_select also accepts a numeric column index. See ?tidyselect::language
for full details on the selection language.}

\item{read_fun}{The name of a function to read data. for 'readr' functions,
you only have to specify the function name (e.g., `read_csv()`). If you use
a function from another package, name the package explicitly
(e.g., `haven::read_spss()`).}

\item{row_filter}{Optional rows to include in the results. Uses `dplyr::filter()`.}

\item{row_shuffle}{Optional variables to randomly shuffle.}

\item{long_format}{Logical indicating whether the data are in long format
(only relevant when shuffling variables using row_shuffle).}

\item{seed}{integer used for replicability purposes when randomly shuffling
data.}

\item{dots_chr}{Additional arguments for the read function, parsed as a string}
}
\description{
Construct code that is used to read new data
}
\keyword{internal}
