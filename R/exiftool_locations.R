#' Sets iptc and xmp location tags from each other respectively
#' 
#' @description Sets the tags for city, province and country from IPTC group to XMP group and vice versa.
#' Goal is to have all available location info identical in both groups. This is necessary because many
#' programs consider different groups for that information which leads to inconsistencies.
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
complete_location <- function(paths,
                              csv_execute = TRUE,
                              csv_path = '~/Pictures/locations.csv',
                              delete_original = FALSE){
  
  req_columns = c("SourceFile", "IPTCDigest",
                  "XMP:City", "IPTC:City",
                  "XMP:State", "IPTC:Province-State", 
                  "XMP:Country", "IPTC:Country-PrimaryLocationName")
  args <- c("-G", "-s",
            paste0("-", req_columns[2]),
            paste0("-", req_columns[3]),
            paste0("-", req_columns[4]),
            paste0("-", req_columns[5]),
            paste0("-", req_columns[6]),
            paste0("-", req_columns[7]))
  locations <- exiftoolr::exif_read(args = args, path = paths)
  
  # check if one of the desired tags is completely missing and add it if necessary
  missing_col = req_columns[!(req_columns %in% colnames(locations))]
  missing <- tibble::as_tibble(matrix(ncol = length(missing_col), nrow = 1, dimnames = list(NULL, missing_col)))
  locations <- locations |> 
    tibble::add_column(missing) |>
    dplyr::select(all_of(req_columns))
  
  # now fill missing cross-value tags, prio is IPTC 
  locations <- locations |> 
    dplyr::mutate(`XMP:City` = ifelse(!is.na(`IPTC:City`), `IPTC:City`, `XMP:City`)) |> 
    dplyr::mutate(`XMP:Country` = ifelse(!is.na(`IPTC:Country-PrimaryLocationName`), `IPTC:Country-PrimaryLocationName`, `XMP:Country`)) |> 
    dplyr::mutate(`XMP:State` = ifelse(!is.na(`IPTC:Province-State`), `IPTC:Province-State`, `XMP:State`)) |> 
    dplyr::mutate(`IPTC:City` = ifelse(is.na(`IPTC:City`), `XMP:City`, `IPTC:City`)) |> 
    dplyr::mutate(`IPTC:Province-State` = ifelse(is.na(`IPTC:Province-State`), `XMP:State`, `IPTC:Province-State`)) |> 
    dplyr::mutate(`IPTC:Country-PrimaryLocationName` = ifelse(is.na(`IPTC:Country-PrimaryLocationName`), `XMP:Country`, `IPTC:Country-PrimaryLocationName`)) |> 
    dplyr::mutate(IPTCDigest = "-")
  
  handle_return(locations, csv_execute, paths, csv_path, delete_original)
}
