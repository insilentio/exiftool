#' Transfer metadata of photos in one directory to similar photos in another directory
#' 
#' @description Sometimes there are discrepancies in metadata between the original photos and the ones
#' in Export Album. This code helps to transfer all relevant metadata to the exported photos in one go, for whole directories.
#'
#' @param path_to full target path. Photos in this directory get updated
#' @param path_from full origin path. Photos in this directory are the source of metadata
#' @param modified_since helps to restrict affected photos to the ones modified since that date, 
#' e.g. when updating metadata in ON1, they can then be easily transferred to existing Export photos.
#' Set it to something like "01-01-1900" if you want to include all. Defaults to today
#' @param ignore_warnings Should the photos be updated if the plausibility tests go wrong? Default is FALSE.
#' @param delete_original Should the backup photos of exiftool be deleted in the end? Default is FALSE.
#'
#' @returns exiftool output
#' @export
transfer_metadata <- function(path_to,
                              path_from,
                              modified_since = Sys.Date(),
                              ignore_warnings = FALSE,
                              delete_original = FALSE){
  
  # we can restrict the list of original files by modified date
  # this is very helpful if some photos were e.g. updated with metadata
  files_from <- file.info(list.files(path_from,
                                     recursive = TRUE,
                                     full.names = TRUE)) |> 
    tibble::rownames_to_column("path_from") |> 
    dplyr::select(path_from, mtime) |> 
    dplyr::filter(mtime >= modified_since) |> 
    dplyr::mutate(match = stringr::str_extract(path_from, ".*(?=\\..*)"))
  
  
  files_to <- tibble::tibble(
    path_to = list.files(path_to,
                         recursive = TRUE,
                         full.names = TRUE)
  ) |>
    dplyr::filter(stringr::str_ends(path_to, "jpg")) |> 
    dplyr::mutate(name_to = stringr::str_extract(path_to, "[0-9]{4}-.*")) |> 
    dplyr::mutate(dir_to = stringr::str_sub(path_to, 1, nchar(path_to) - nchar(name_to))) |> 
    dplyr::mutate(name_from = stringr::str_remove(name_to, "[0-9]{4}-([0-9]{2}[-_]){5}")) |> 
    dplyr::mutate(dir_from = stringr::str_replace(dir_to, ".*\\/ExportAlbum", "/Users/Daniel/Pictures/Album")) |> 
    dplyr::mutate(match = paste0(dir_from, name_from)) |>
    dplyr::mutate(match = stringr::str_sub(match, 1, nchar(match) - 4)) 
  
  # make sure that you get the expected sizes for each dataframe (not necessarily the same!)
  # check with these helpers for duplicates and ensure for every files_from there is also a file_to present:
  if (!ignore_warnings) {
    stopifnot(exprs = {
      files_to |> 
        dplyr::group_by(match) |> 
        dplyr::filter(dplyr::n() > 1) |> 
        nrow() == 0
      
      files_from |> 
        dplyr::group_by(match) |> 
        dplyr::filter(dplyr::n() > 1) |> 
        nrow() == 0
      
      nrow(files_from) == nrow(files_to |>
                                 dplyr::inner_join(files_from, by = "match"))
    }
    )
  }
  
  files <- files_from |>
    dplyr::left_join(files_to, by = "match") |> 
    dplyr::select(match, path_to, path_from)
  
  for (i in 1:nrow(files)) {
    args <- c("-exif:all=", "-xmp:all=", "-iptc:all=", "-iptcdigest=", "-tagsfromfile", files$path_from[i],
              "-exif:all", "-xmp:all", "-iptc:all", "--on1ref", "--orientation", "-makernotes:all=", "-m")
    if (delete_original)
      args <- c(args, "-delete_original")
    
    exiftoolr::exif_call(args = args, path = files$path_to[i])
  }
}
