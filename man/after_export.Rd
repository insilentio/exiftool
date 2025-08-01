% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/after_export.R
\name{after_export}
\alias{after_export}
\title{Do after-export work}
\usage{
after_export(imp_path, exp_path = NULL)
}
\arguments{
\item{imp_path}{the path where the originals lie. Function will remove any xmp in this path}

\item{exp_path}{the path where the exported photos lie. If left empty, function expects to find them in exif-export.csv}
}
\value{
nothing
}
\description{
Necessary tasks after reading in the previously updated originals and creating the jpg exports from ON1.
\itemize{
\item Deletes xmp files in import folder
\item runs metadata functions to complete metadata which is missing after export (35mm focal length, lens info).
}
}
