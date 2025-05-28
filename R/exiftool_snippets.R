
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
  paths <- read_csv(input, trim_ws = FALSE) |> 
    select(1, 5, "Objektivmodell") |> 
    rename(file = 1, path = 2, type = 3) |> 
    mutate(full = paste0(path, "/", file))
  
  paths
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
                         output = "~/Pictures/Album/paths.txt") {
  write_csv2(paths |> 
             select(full),
             output,
             col_names = FALSE)
}
