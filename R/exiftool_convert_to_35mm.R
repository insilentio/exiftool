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
convert35 <- function(paths,
                      csv_execute = TRUE,
                      csv_path = '~/Pictures/fl.csv',
                      delete_original = FALSE){
  
  args <- c("-G", "-s", "-n", "-exif:focallength*", "-exif:model", "-exif:lensmodel")
  exifvalues <- exiftoolr::exif_read(args = args, path = paths)
  
  # Real cameras always have the same scaling factor for all lenses, smartphones have different ones
  # per lens. Therefore the mapping table's primary key sometimes consists of 1 column, sometimes of 2.
  # There's no elegant way to do the joining for that reason, so we have to do it in 2 steps and then
  # merge it together.
  focallength_1 <- exifvalues |> 
    dplyr::rename(fl35Original = `EXIF:FocalLengthIn35mmFormat`) |> 
    dplyr::left_join(exifer::cropFactor,
                     by = dplyr::join_by("EXIF:Model" == "model", "EXIF:LensModel" == "lensmodel"))
  focallength_2 <- focallength_1 |> 
    dplyr::filter(is.na(factor)) |> 
    dplyr::select(SourceFile, `EXIF:FocalLength`, fl35Original, `EXIF:Model`, `EXIF:LensModel`) |> 
    dplyr::left_join(exifer::cropFactor |> dplyr::select(-lensmodel),
                     by = dplyr::join_by("EXIF:Model" == "model"))
    
  focallength <- focallength_1 |> 
    dplyr::filter(!is.na(factor)) |> 
    dplyr::add_row(focallength_2) |> 
    dplyr::mutate(`EXIF:FocalLengthIn35mmFormat` = ifelse(is.na(fl35Original),
                                                          floor(`EXIF:FocalLength`*factor),
                                                          fl35Original)) |> 
    dplyr::select(SourceFile, `EXIF:FocalLengthIn35mmFormat`)
  
  handle_return(focallength, csv_execute, paths, csv_path, delete_original)
}
