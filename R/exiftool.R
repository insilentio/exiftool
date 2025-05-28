# update after ON1 migration

library(exiftoolr)
library(tidyverse)



##update with lr hierarchical keywords where necessary
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

#XMP-mediapro
grp <- "XMP-mediapro:all"
argsread <- c(argsread, paste0("-", grp))

#XMP-acdsee
grp <- "XMP-acdsee:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-microsoft:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-digikam:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-crs:all"
argsread <- c(argsread, paste0("--", grp))

grp <- "XMP-crss:all"
argsread <- c(argsread, paste0("--", grp))

grp <- "xmpMM:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-photoshop:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-lr:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-video:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-tiff:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-mp:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-mwg-rs:all"
argsread <- c(argsread, paste0("-", grp))

grp <- "XMP-iptcext:all"
argsread <- c(argsread, paste0("-", grp))

tags <- exif_call(args = argsread, path = path, intern = TRUE)
tags <- tibble(
  X1 = gsub("\\s+.+\\s*: .+", "", tags),
  X2 = gsub("(.+\\]\\s+|\\s*: .+)", "", tags),
  X3 = trimws(str_split(gsub(".*\\: ", "", tags), ",")))
tags <- tags %>% 
  distinct(X1, X2, .keep_all = T) %>% 
  arrange(X1, X2)

