#' Read PhotoStatistica exif_export.csv for path creation
#' 
#' The function extracts the different info from the exif_export file from PhotoStatistica
#' and calculates the indidividual file paths. They are then written to a file which can be
#' used with exiftool with the "-@" option
#'
#' @param input path to the exif-export csv file
#'
#' @returns the calculated paths as a tibble
#' @export 
#'
#' @examples extract_paths()
extract_paths <- function(input = "~/Pictures/Exif-export.csv") {
  read_csv(input, trim_ws = FALSE) |> 
    select(1, 5, "Objektivmodell") |> 
    rename(file = 1, path = 2, type = 3) |> 
    mutate(full = paste0(path, "/", file))
}


#' Write complete path names into csv file
#'
#' @param paths a tibble of path information obtained by extract_paths()
#' @param output path to the desired output csv file
#'
#' @returns Invisibly writes a csv file into output
#' @export
#'
#' @examples output_paths(extract_paths())
output_paths <- function(paths,
                         output = "~/Pictures/paths.txt") {
  write_csv2(paths |> select(full),
             output,
             col_names = FALSE)
}


#' Handles the outcome of the various exiftool functions
#' 
#' @description depending on param csv_execute, either writes a csv_file
#'
#' @param df tibble or dataframe with the file and metadata information. Usually created within one
#' of the exiftool_ file functions.
#' @param csv_execute logical, to determine whether modification should be directly written or returned as tibble
#' @param paths List of photos to be modified. Needs a character vector with full file names
#' @param csv_path path and file name of the output csv file
#' @param delete_original whether the original copies of the photos should be deleted afterwards or not
#' @param with_sep for list type tags like keywords, you need to indicate which separator is used
#'
#' @returns depending on param csv_execute:
#' - if TRUE,  writes the tag values as csv file and writes them via exiftool to pictures
#' - if FALSE, returns the tags as tibble
#' @export
#'
#' @examples
handle_return <- function(df, csv_execute, paths, csv_path, delete_original, with_sep = NULL) {
  
  if (is.null(with_sep))
    sep <- ""
  else
    sep <- paste0("-sep '", with_sep, "'")
  
  if (csv_execute){
    loc_path <- normalizePath(csv_path, mustWork = FALSE)
    df |> write_csv(loc_path)
    
    exif_call(args = c("-f", paste0("-csv=", loc_path)), common_args = sep, path = paths)
    
    if (delete_original)
      exif_call(args = c("-r", "-delete_original!"), path = unique(dirname(paths)))
  } else {
    df
  }
}
