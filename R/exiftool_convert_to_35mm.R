#' amend crop factor information for focallength bases on a mapping table
#' 
#' @description Writes the tag for equivalent focal length in 35mm format into photo metadata.
#' Relies on a hardcoded mapping table (CropFactor.csv).
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
#' @examples convert35("Test.jpg")
convert35 <- function(paths,
                      csv_execute = TRUE,
                      csv_path = '~/Pictures/fl.csv',
                      delete_original = FALSE){
  
  require(exiftoolr)
  require(dplyr)
  
  mapping <- read_csv("Data/CropFactor.csv")
  
  args <- c("-G", "-s", "-n", "-exif:focallength", "-exif:model")
  focallength <- exif_read(args = args, path = paths) |> 
    left_join(mapping, by = join_by("EXIF:Model" == "model")) |> 
    mutate(`EXIF:FocalLengthIn35mmFormat` = `EXIF:FocalLength`*factor)
  
  handle_return(focallength, csv_execute, paths, csv_path, delete_original)
}
