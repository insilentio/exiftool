#' Do after-export work
#' 
#' @description Necessary tasks after reading in the previously updated originals and creating the jpg exports from ON1.

#' 1. Deletes xmp files in import folder
#' 2. runs metadata functions to complete metadata which is missing after export (35mm focal length, lens info, keywords).
#'
#' @param imp_path the path where the originals lie. Function will remove any xmp in this path
#' @param exp_path the path where the exported photos lie. If left empty, function expects to find them in exif-export.csv
#'
#' @returns nothing
#' @export
after_export <- function(imp_path, exp_path = NULL){
  if (is.null(exp_path)){
    if (!rstudioapi::showQuestion(title = "Exif_export", message="exif-export.csv generated?")) {
      stop("Aborted, please create exif_export.csv first or provide export path")
    }
  }

  # ON1 generates new xmp upon "read metadata from photo" in the previous step, let's delete them again
  system(paste0('find "', imp_path, '" -name "*xmp" -exec rm {} \\;'))
  
  # ON1 does not export 35mm focal length info nor lens type, must be added after jpg generation
  if (is.null(exp_path)) {
    # -> generate the list of affected files first in Photo Statistica
    paths <- extract_paths() |> 
      dplyr::pull(full)
  } else {
    paths <- list.files(exp_path,
                        recursive = TRUE,
                        full.names = TRUE)
  }
  
  fs <- flatten_subject(paths, csv_execute = FALSE)
  hl <- harmonize_lensinfo(paths, csv_execute = FALSE)
  
  modify <- fs |> 
    dplyr::full_join(hl) 
  
  handle_return(modify, csv_execute = TRUE, paths = exp_path, csv_path = '~/Pictures/exifer.csv', delete_original = TRUE)
}
