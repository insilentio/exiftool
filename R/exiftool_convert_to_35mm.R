# amend crop factor information
# (hardcoded in a mapping table)
# mapping table


convert35 <- function(path, csv_execute = TRUE){
  require("exiftoolr")
  
  mapping <- read_csv("Data/CropFactor.csv")
  
  args <- c("-G", "-s", "-n", "-exif:focallength", "-exif:model")
  focallength <- exif_read(args = args, path = path)
  
  focallength <- focallength |> 
    left_join(mapping, by = join_by("EXIF:Model" == "model")) |> 
    mutate(`EXIF:FocalLengthIn35mmFormat` = `EXIF:FocalLength`*factor)
  
  if (csv_execute) {
    # now use the csv option of exifool to handle different values for different files
    # this is much faster than a for loop which calls exiftool every time
    loc_path <- normalizePath('~/Pictures/fl.csv', mustWork = FALSE)
    focallength |> write_csv(loc_path)

  exif_call(args = c("-f", paste0("-csv=", loc_path)), path = path)
  } else {
    focallength
  }
}
