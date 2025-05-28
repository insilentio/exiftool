# Performs necessary steps on metadata side for new pictures
# in Import folder after Development work in ON1

library(exiftoolr)
library(tidyverse)
source("Code/Exiftool/exiftool_snippets.R")

# current import path
imp_path <- "/Volumes/NoBackup/Bilder/Import/2025"

system(paste0("exiftool -r -ext nef -tagsfromfile ", imp_path, "/%-1:d%f.xmp ", imp_path))
system(paste0("find ", imp_path, " -name '*xmp' -exec rm {} \\;"))
system(paste0("exiftool -r -delete_original! ", imp_path))

# get a list of file names in Import/2025
imported <- list.files(imp_path,
                       recursive = TRUE,
                       full.names = TRUE)

flatten_subject(imported)
system(paste0("exiftool -r -delete_original! ", imp_path))
