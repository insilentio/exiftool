# simple code to flatten hierarchical subjects
# as default uses the paths indicated in Exif-info.csv which is generated
# by PhotoStatistica

library(exiftoolr)
library(tidyverse)


paths <- extract_paths() |> 
  pull(full)

flatten_subject(paths)