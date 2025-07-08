#' Do after-export work
#' 
#' @description Necessary tasks after reading in the previously updated originals and creating the jpg exports from ON1.
#' - Deletes xmp files in import folder
#' - runs metadata functions to complete metadata which is missing after export (35mm focal length, lens info).
#'
#' @param imp_path the path where the originals lie. Function will remove any xmp in this path
#'
#' @returns nothing
#' @export
#'
#' @examples after_export()
after_export <- function(imp_path = "/Volumes/NoBackup/Bilder/Import/2025/"){
  
  # ON1 generates new xmp upon "read metadata from photo" in the previous step, let's delete them again
  system(paste0("find '", imp_path, "' -name '*xmp' -exec rm {} \\;"))
  
  # ON1 does not export 35mm focal length info nor lens type, must be added after jpg generation
  # -> generate the list of affected files first in Photo Statistica
  if (showQuestion(title = "Exif_export", message="exif-export.csv generated?")){
    paths <- extract_paths() |> 
      pull(full)
    
    convert35(paths)
    harmonize_lensinfo(paths, delete_original = TRUE)
    
  } else {
    showDialog("Exif_export", message = "Aborted, please create exif_export.csv first")
  }
}
