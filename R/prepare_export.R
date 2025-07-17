#' Prepare originals for export
#' 
#' @description Performs necessary steps on metadata side for new pictures
#' in Import folder after Development work in ON1 and before Export
#' 
#' 1. copy xmp metadata information onto original file
#' 2. remove unnecessary side files
#' 3. flatten hierarchical keywords for writing into keywords and subject tag
#' 4. amend lens information for Nikon in order to have consistent metadata
#' 5. amend lens information for Apple in order to have prime/zoom lens info consistent
#' 6. ensures completeness of location tags information
#' 7. cleanup
#'
#' @param imp_path current import path to work on. The number of subordinate directory levels is indicated
#' by the parameter 'level_below'.
#' @param level_below indicates to which directory level relative to imp_path it is looking for xmp files and
#' therefore may need to be changed (e.g. on year level -> 2, on album level -> 3)
#'
#' @returns nothing
#' @export
prepare_export <- function(imp_path = "/Volumes/NoBackup/Bilder/Import/2025/", level_below = "1"){
  
  # Write XMP into original files and cleanup ----------------------------------------------------
  # (this needs to be done because ON1 writes NEF file metadata mostly into xmp)
  exiftoolr::exif_call(args = c("-r", "-ext", "nef", "-tagsfromfile", paste0(imp_path, "/%-", level_below, ":d%f.xmp")),
            path = imp_path)
  system(paste0("find '", imp_path, "' -name '*xmp' -exec rm {} \\;"))
  exiftoolr::exif_call(args = c("-r", "-delete_original!"), path = imp_path)
  
  
  # generate file list and run metadata functions ---------------------------
  
  # get complete file list
  imported <- list.files(imp_path,
                         recursive = TRUE,
                         full.names = TRUE)
  
  # flatten hierarchical keywords
  flatten_subject(imported)
  
  
  # lens information
  harmonize_lensinfo(imported)
  
  
  # complete the information in the various location tags
  complete_location(imported)
  
  
  # open issues -------------------------------------------------------------
  
  # focal length 35mm?
  # convert35(imported)
  
  
  # final cleanup -----------------------------------------------------------
  
  exiftoolr::exif_call(args = c("-r", "-delete_original!"), path = imp_path)
}
