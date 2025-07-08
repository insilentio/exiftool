#' Flatten hierarchical keywords
#' 
#' @description Write flat keywords and subject tags derived from hierarchical ones (tag XMP:HierarchicalSubject)
#' into photo metadata. Only writes the lowest level keywords back to the pictures. Hierarchical keyword tag is not modified. 
#' It uses per default the csv option of exifool to handle different values for different files,
#' which is much faster than a for loop which calls exiftool every time.
#' Exiftool per default creates copies of the original files (*_original); this behaviour can be modified by parameter.
#'
#' @param paths List of photos to be modified. Needs a character vector with full file names
#' @param csv_execute logical, to determine whether modification should be directly written or returned as tibble
#' @param csv_path path and file name of the output csv file
#' @param delete_original whether the original copies of the photos should be deleted afterwards or not
#'
#' @returns depending on param csv_execute:
#' - if TRUE,  writes the tag values as csv file and writes them via exiftool to pictures
#' - if FALSE, returns the tags as tibble
#' @export
#'
#' @examples flatten_subject("Test.jpg")
flatten_subject <- function(paths,
                            csv_execute = TRUE,
                            csv_path = '~/Pictures/subjects.csv',
                            delete_original = FALSE){
  
  args <- c("-G", "-s", "-hierarchicalsubject")
  
  subjects <- exif_read(args = args, path = paths) |> 
    mutate(subject = lapply(`XMP:HierarchicalSubject`, str_extract, pattern = "([^\\|]+)$")) |> 
    mutate(subject = lapply(subject, function(x) paste(unlist(x), sep='', collapse=', '))) |>
    mutate(subject = unlist(subject)) |> 
    select(SourceFile, subject) |> 
    mutate(`IPTC:Keywords` = subject) |> 
    rename(`XMP:Subject` = subject)
  
  handle_return(subjects, csv_execute, paths, csv_path, delete_original, with_sep = ", ")
}
