# write the lensinfo tag dynamically based on information from
# Photostatisticas exif-info.csv

library(dplyr)
library(readr)

# read PhotoStatistica exif_export.csv for path creation
source("R/exiftool_snippets.R")
source("R/create_lensinfo.R")
paths <- extract_paths()

# identify lens models
models <- paths |> 
  distinct(type)

# update the information for each model
for (i in 1:nrow(models)) {
# get the paths for all images with this lens model and write them to file
  loc_paths <- paths |> 
    filter(type == pull(models[i,]))
  output_paths(loc_paths)  
  
  # generate the lens info (for zoom or prime) from the lensmodel
  
  lenses <- create_lensinfo(loc_paths |> 
                    slice(1) |> 
                    select(type))
  
  # write the lens info to csv file
  tibble(lenses) |> 
    write_csv("~/Pictures/Album/lenses.txt",
              col_names = FALSE)
  
  # execute system command
  system("exiftool -@ ~/Pictures/Album/lenses.txt -@ ~/Pictures/Album/paths.txt")
}
