# file contains various manual code which has been used in the context of metadata cleanup

library(exiftoolr)
library(dplyr)
library(readr)
source("R/helpers.R")
source("R/exiftool_locations.R")
source("R/exiftool_flatten.R")
source("R/prepare_export.R")

# run the metadata enrichment stuff before exporting photos from ON1
prepare_export(imp_path = "/Volumes/NoBackup/Bilder/Import/2025/33 - Geburri Ladina/", level_below = "0")
# ON1 generates new xmp upon "read metadata from photo", let's delete them again
system(paste0("find '", imp_path, "' -name '*xmp' -exec rm {} \\;"))


# renaming helper ----------------------------------------------------------
# this renames pictures based on a manually created csv file
naming <- read_csv("~/Pictures/names.csv") |> 
  select(OLDNAME, NEWNAME)

for (i in 1:nrow(naming)){
  cmd <- paste0("mv '", naming[i, 1], "' '", naming[i, 2], "'")
  
  system(cmd)
}


# call location completer manually ----------------------------------------
#  (usually via prepare_import)
path <- '/Volumes/NoBackup/Bilder/Export/ExportAlbum/2021/30 - Herbstferien Kroatien/'
path <- list.files(path,
                   full.names = TRUE)
complete_location(path)



# flatten keywords --------------------------------------------------------
# simple code to flatten hierarchical subjects
# as default uses the paths indicated in Exif-info.csv which is generated
# by PhotoStatistica
paths <- extract_paths() |> 
  pull(full)

flatten_subject(paths)



# update after ON1 migration ----------------------------------------------# 
##update with lr hierarchical keywords where necessary
# this needs a file which was lost :-(
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

