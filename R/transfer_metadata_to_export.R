# Sometimes there are discrepancies in metadata between the original photos and the ones 
# in Export Album.
# This code helps to transfer all relevant metadata to the exported photos in one go, for whole directories.
# Parameter "modified_since" helps to restrict affected photos to the ones modified since that date,
# e.g. when updating metadata in ON1, they can then be easily transferred to existing Export photos.


path_to <- "/Volumes/NoBackup/Bilder/Export/ExportAlbum/2022/34 - Ausflug Jonduri und Papa/"
path_from <- "/Users/Daniel/Pictures/Album/2022/34 - Ausflug Jonduri und Papa/"
modified_since <- "2025-06-20"

library(tibble)
library(dplyr)
library(stringr)
library(exiftoolr)
source("R/helpers.R")

# we can restrict the list of original files by modified date
# this is very helpful if some photos were e.g. updated with metadata
# just put the mtime to something like "01-01-1900" if you want to include all
files_from <- file.info(list.files(path_from,
                                   recursive = TRUE,
                                   full.names = TRUE)) |> 
  rownames_to_column("path_from") |> 
  select(path_from, mtime) |> 
  filter(mtime >= modified_since) |> 
  mutate(match = str_extract(path_from, ".*(?=\\..*)"))


files_to <- tibble(
  path_to = list.files(path_to,
                    recursive = TRUE,
                    full.names = TRUE)
  ) |>
  filter(str_ends(path_to, "jpg")) |> 
  mutate(name_to = str_extract(path_to, "[0-9]{4}-.*")) |> 
  mutate(dir_to = str_sub(path_to, 1, nchar(path_to) - nchar(name_to))) |> 
  mutate(name_from = str_remove(name_to, "[0-9]{4}-([0-9]{2}[-_]){5}")) |> 
  mutate(dir_from = str_replace(dir_to, ".*\\/ExportAlbum", "/Users/Daniel/Pictures/Album")) |> 
  mutate(match = paste0(dir_from, name_from)) |>
  mutate(match = str_sub(match, 1, nchar(match) - 4)) 

# make sure that you get the expected sizes for each dataframe
# for a complete transfer, files_to and files_from need to be the same size!
# check also with these helpers for duplicates etc.:
files_to |> 
  group_by(match) |> 
  filter(n() > 1) |> 
  pull(path_to)

files_from |> 
  group_by(match) |> 
  filter(n() > 1) |> 
  pull(path_from)

files_anti <- files_to |> 
  anti_join(files_from, by = "match") |> 
  select(match)
# end of checks


files <- files_from |>
  left_join(files_to, by = "match") |> 
  select(match, path_to, path_from)

for (i in 1:nrow(files)) {
  args <- c("-exif:all=", "-xmp:all=", "-iptc:all=", "-iptcdigest=", "-tagsfromfile", files$path_from[i],
            "-exif:all", "-xmp:all", "-iptc:all", "--on1ref", "--orientation", "-makernotes:all=", "-m")
  
  exif_call(args = args, path = files$path_to[i])
}
