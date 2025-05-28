library(dplyr)
library(readr)

# read PhotoStatistica exif_export.csv for path creation
source("Code/exiftool_snippets.R")
paths <- extract_paths()

models <- paths |> 
  distinct(type)

for (i in 1:nrow(models)) {
  loc_paths <- paths |> 
    filter(type == pull(models[i,]))
  
  
  # generate the lens info (for zoom or prime) from the lensmodel
  typenew = as.data.frame(
    stringr::str_extract_all(loc_paths |> 
                               slice(1) |> 
                               select(type),
                             "[0-9.]{1,5}", simplify = TRUE))

  info <- if (ncol(typenew) == 2) {
    typenew |> 
      mutate(V3 = V1, V4 = V2) |> 
      mutate(V5 = paste(V1, V3, V2, V4)) |> 
      select(5)
  } else if (ncol(typenew) == 3) {
    typenew |> 
      mutate(V4 = V3) |> 
      mutate(V5 = paste(V1, V2, V3, V4)) |> 
      select(5)
  } else if (ncol(typenew) == 4) {
    typenew |> 
      mutate(V5 = paste(V1, V2, V3, V4)) |> 
      select(5)  
  }

  lenses <- c(paste0("-exif:lensinfo=", info),
              paste0("-xmp:lensinfo=", info))
  
  # write the two csv files
  tibble(lenses) |> 
    write_csv("~/Pictures/Album/lenses.txt",
              col_names = FALSE)
  
  output_paths(loc_paths)
  
  system("exiftool -@ ~/Pictures/Album/lenses.txt -@ ~/Pictures/Album/paths.txt")
}
