% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transfer_metadata_to_export.R
\name{transfer_metadata}
\alias{transfer_metadata}
\title{Transfer metadata of photos in one directory to similar photos in another directory}
\usage{
transfer_metadata(
  path_to,
  path_from,
  modified_since = Sys.Date(),
  ignore_warnings = FALSE,
  delete_original = FALSE
)
}
\arguments{
\item{path_to}{full target path. Photos in this directory get updated}

\item{path_from}{full origin path. Photos in this directory are the source of metadata}

\item{modified_since}{helps to restrict affected photos to the ones modified since that date,
e.g. when updating metadata in ON1, they can then be easily transferred to existing Export photos.
Set it to something like "01-01-1900" if you want to include all. Defaults to today}

\item{ignore_warnings}{Should the photos be updated if the plausibility tests go wrong? Default is FALSE.}

\item{delete_original}{Should the backup photos of exiftool be deleted in the end? Default is FALSE.}
}
\value{
exiftool output
}
\description{
Sometimes there are discrepancies in metadata between the original photos and the ones
in Export Album. This code helps to transfer all relevant metadata to the exported photos in one go, for whole directories.
}
