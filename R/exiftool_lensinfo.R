#' Generates the lens info (for zoom or prime) from the lensmodel
#' 
#' @description Format is: min focal range, max focal range, min aperture @ min range, min aperture @ max range
#' for primes, V2 and V4 are identical to V1 and V3 respectively
#'
#' @param lensmodel the lensmodel information from the respective metadata tag (usually from exiftool)
#' @param as_tags if TRUE, function returns lensinfo as exiftool arguments, else as raw information
#'
#' @returns a tibble with either the raw lensinfo or already prepared as exiftool arguments, depending on param as_tags
#' @export
create_lensinfo <- function(lensmodel, as_tags = TRUE){
  
  typenew = as.data.frame(
    stringr::str_remove(lensmodel, ".* (?=[0-9.]{1,5}mm)") |> 
      stringr::str_extract_all("[0-9.]{1,5}", simplify = TRUE))
  
  # build proper format
  info <- (if (ncol(typenew) == 2) {
    typenew |> 
      mutate(V3 = V1, V4 = V2) |> 
      mutate(V5 = paste(V1, V3, V2, V4)) 
  } else if (ncol(typenew) == 3) {
    typenew |> 
      mutate(V4 = V3) |> 
      mutate(V5 = paste(V1, V2, V3, V4)) 
  } else if (ncol(typenew) == 4) {
    typenew |> 
      mutate(V5 = paste(V1, V2, V3, V4)) 
  }) |> 
    select(5) |> 
    pull()
  
  # prepare the lens tag
  lenses <- c(paste0("-exif:lensinfo=", info),
              paste0("-xmp:lensinfo=", info))
  
  if (as_tags)
    lenses
  else
    info
}


#' Write lens information
#' 
#' @description Writes various lens information tags obtained from a mapping table (LensMapping.csv) and existing metadata
#' into photo metadata. LensInfo is created dynamically and can be written separately by the according parameter
#' (this is often necessary because programs omit this information which is relevant for prime/zoom differentiation). 
#' It uses per default the csv option of exifool to handle different values for different files,
#' which is much faster than a for loop which calls exiftool every time
#'
#' @param paths List of photos to be modified. Needs a character vector with full file names
#' @param csv_execute logical, to determine whether modification should be directly written or returned as tibble
#' @param csv_path path and file name of the output csv file
#' @param delete_original whether the original copies of the photos should be deleted afterwards or not
#' @param lensinfo_only if TRUE, only the tag "lensinfo" is changed (this is often omitted by many programs)
#'
#' @returns depending on param csv_execute:
#' - if TRUE,  writes the tag values as csv file and writes them via exiftool to pictures
#' - if FALSE, returns the tags as tibble
#' @export
harmonize_lensinfo <- function(paths,
                               csv_execute = TRUE,
                               csv_path = '~/Pictures/subjects.csv',
                               delete_original = FALSE,
                               lensinfo_only = FALSE){
  
  args <- c("-G", "-s", "-n", "-lensinfo", "-lensmodel", "-lens", "-lensmake")

  # read only metadata of photos where LensModel is known
  li <- exiftoolr::exif_read(args = args, path = paths) |> 
    dplyr::filter(!is.na(`EXIF:LensModel`))
  
  # check if the lensinfo tag is completely missing and add it if necessary
  if (!"EXIF:LensInfo" %in% colnames(li))
    li <- li |> tibble::add_column("EXIF:LensInfo" = NA)

  # amend Nikon and Apple lens information
  # means lower case for lensmake and adaptation of lensmodel

  # mapping table
  mapping <- readr::read_csv("Data/LensMapping.csv")
  
  # change the information by joining the mapping table
  modify <- li |> 
    dplyr::mutate(`EXIF:LensMake` = ifelse(`EXIF:LensMake` == "NIKON", "Nikon", `EXIF:LensMake`)) |> 
    dplyr::left_join(mapping, by = join_by(`EXIF:LensModel` == model_old)) |> 
    dplyr::mutate(`EXIF:LensModel` = ifelse(is.na(model_new), `EXIF:LensModel`, model_new)) |> 
    dplyr::mutate(`XMP:Lens` = `EXIF:LensModel`) |> 
    dplyr::mutate(`EXIF:LensInfo` = ifelse((is.na(`EXIF:LensInfo`) | (`EXIF:LensMake` == "Apple")),
                             unlist(Vectorize(create_lensinfo)(`EXIF:LensModel`, FALSE)),
                             `EXIF:LensInfo`)) |> 
    dplyr::mutate(`XMP:LensInfo` = `EXIF:LensInfo`) |> 
    dplyr::select(-model_new)
  
  if (lensinfo_only) {
    modify <- modify |> 
      dplyr::select(SourceFile, `EXIF:LensInfo`, `XMP:LensInfo`)
  }
  
  handle_return(modify, csv_execute, paths, csv_path, delete_original)
}
