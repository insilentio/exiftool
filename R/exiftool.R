# file contains various manual code which has been used in the context of metadata cleanup

library(exiftoolr)
library(dplyr)
library(readr)
library(lubridate)
library(rstudioapi)
library(stringr)
source("R/helpers.R")
source("R/exiftool_locations.R")
source("R/exiftool_flatten.R")
source("R/prepare_export.R")
source("R/exiftool_lensinfo.R")
source("R/exiftool_convert_to_35mm.R")


# default metadata work before and after ON1 export -----------------------
# select import folder to act upon
imported <- selectDirectory(caption = "Select directory",
                            path = paste0("/Volumes/NoBackup/Bilder/Import/", year(Sys.Date())))
# tries automagically to determine on which level the prepare_export() should be run
lb <- abs((str_extract(imported, "\\/(Bilder|Pictures).*") |> 
  str_count("\\/")) - 4 )

# run the metadata enrichment stuff before exporting photos from ON1
prepare_export(imp_path = imported, level_below = lb)

# run the cleanup and metadata enrichment stuff after jpg export from ON1
after_export(imp_path = imported)


# metadata transfer -------------------------------------------------------

path_to <- "/Volumes/NoBackup/Bilder/Export/ExportAlbum/2022/34 - Ausflug Jonduri und Papa/"
path_from <- "/Users/Daniel/Pictures/Album/2022/34 - Ausflug Jonduri und Papa/"
modified_since <- "2025-06-20"

transfer_metadata(path_to, path_from, modified_since, delete_original = TRUE)

# renaming helper ----------------------------------------------------------
# this renames pictures based on a manually created csv file
# (to make file names more congruent, e.g. adding the camera model)
naming <- read_csv("~/Pictures/names.csv") |> 
  select(OLDNAME, NEWNAME)

for (i in 1:nrow(naming)){
  cmd <- paste0("mv '", naming[i, 1], "' '", naming[i, 2], "'")
  
  system(cmd)
}


# call location completer manually ----------------------------------------
#  (usually via prepare_import)
complete_location(paths)


# flatten keywords --------------------------------------------------------
#  (usually via prepare_import)
flatten_subject(paths)


# update after ON1 migration ----------------------------------------------# 
##update with lr hierarchical keywords where necessary
# this needs a file which was lost :-(
# (this is some old code which I don't really know what it was used for)
paths <- extract_paths()
argsread <-
  c("-hierarchicalsubject",
    "-subject",
    "-keywords",
    "-tagslist",
    "-category")

mylist <- read_csv("~/Downloads/keywordlist.txt", col_names = F)

#read
(kw <- exif_call(
  args = argsread,
  path = pull(paths),
  intern = TRUE
))
kw <- tibble(X2 = trimws(str_split(gsub(".*\\: ", "", kw), ",")[[1]]))
(tags <- mylist %>%
    right_join(kw, by = "X2"))


#write
exif_call(args = paste0("-hierarchicalsubject=", tags$X1),
          path = paths[i])

#read
exif_call(args = argsread, path = pull(paths[i]))

i <- i + 1


path <- "/Users/Daniel/Pictures/Album/2016/50 - Ausflug nach Fribourg zur CDK/D7200_09015.dng"
##Bereinigung Metadaten, Entfernung von Unnützem
argsread <- c("-a", "-u", "-s", "-G1", "-e")

#potenzielle Duplikate
grp <- c("*catalog*", "*rating*", "*categor*", "*label*", "*caption*", "*tag*", "*keyword*",
         "city*", "*state*", "*state*", "*country*", "*region*")
argsread <- c(argsread, paste0("-", grp))

argsread <- c(argsread,
              "-XMP-mediapro:all",
              "-XMP-acdsee:all",
              "-XMP-microsoft:all",
              "-XMP-digikam:all",
              "-XMP-crs:all",
              "-XMP-crss:all",
              "-xmpMM:all",
              "-XMP-photoshop:all",
              "-XMP-lr:all",
              "-XMP-video:all",
              "-XMP-tiff:all",
              "-XMP-mp:all",
              "-XMP-mwg-rs:all",
              "-XMP-iptcext:all")

tags <- exif_call(args = argsread, path = path, intern = TRUE)
tags <- tibble(
  X1 = gsub("\\s+.+\\s*: .+", "", tags),
  X2 = gsub("(.+\\]\\s+|\\s*: .+)", "", tags),
  X3 = trimws(str_split(gsub(".*\\: ", "", tags), ",")))
tags <- tags %>% 
  distinct(X1, X2, .keep_all = T) %>% 
  arrange(X1, X2)

