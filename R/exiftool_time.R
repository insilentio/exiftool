#' sets datetimeoriginal to createdate
#' 
#' @description
#' Sets the datetimeoriginal tag to the same value as createdate to obtain more coherent time of creation.
#' Especially important for mixed camera scenarioes.
#' Does not solve all time related issues yet, needs more work and clarification with regard to ON1. 
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
harmonize_time <- function(paths,
                           csv_execute = TRUE,
                           csv_path = '~/Pictures/time.csv',
                           delete_original = FALSE){
  
  args <- c("-G", "-s", "-n", "-time:all")
  
  times <- exiftoolr::exif_read(args = args, path = paths)
  
  # check if the dto tag is completely missing and add it if necessary
  if (!"EXIF:DateTimeOriginal" %in% colnames(times))
    times <- times |> tibble::add_column("EXIF:DateTimeOriginal" = NA)
  
  times <- times |> 
    dplyr::mutate(`EXIF:DateTimeOriginal` = `EXIF:CreateDate`) |> 
    dplyr::select(SourceFile, `EXIF:DateTimeOriginal`)
  
  handle_return(times, csv_execute, paths, csv_path, delete_original)
}