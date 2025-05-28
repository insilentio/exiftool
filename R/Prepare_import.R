# Performs necessary steps on metadata side for new pictures
# in Import folder after Development work in ON1
# 
# 1. copy xmp metadata information onto original file
# 2. remove unnecessary side files
# 3. flatten hierarchical keywords for writing into keywords and subject tag
# 4. amend lens information for Nikon in order to have consistent metadata
# 5. amend lens information for Apple in order to have prime/zoom lens info consistent
# 6. ensures completeness of location tags information

library(exiftoolr)
library(tidyverse)
source("R/exiftool_flatten.R")
source("R/exiftool_locations.R")
source("R/create_lensinfo.R")

# current import path
imp_path <- "/Volumes/NoBackup/Bilder/Import/2025"


# XMP to original file ----------------------------------------------------

# write xmp information onto NEF files and cleanup
# (this needs to be done because ON1 writes NEF file metadata mostly into xmp)
system(paste0("exiftool -r -ext nef -tagsfromfile ", imp_path, "/%-1:d%f.xmp ", imp_path))
system(paste0("find ", imp_path, " -name '*xmp' -exec rm {} \\;"))
system(paste0("exiftool -r -delete_original! ", imp_path))


# flatten keywords --------------------------------------------------------

# flatten hierarchical subject
imported <- list.files(imp_path,
                       recursive = TRUE,
                       full.names = TRUE)

flatten_subject(imported)


# lens information --------------------------------------------------------

# lens information changes:
# first read necessary information
li <- exif_read(imported,
                c("lensinfo", "lensmodel", "lens", "lensid", "lensmake"),
                args = c("-s", "-n")) |> 
  filter(!is.na(LensModel))

# amend Nikon and Apple lens information
# means lower case for lensmake and adaptation of lensmodel
# (hardcoded in a mapping table)
#mapping table
mapping <- read_csv("Data/LensMapping.csv")

modify <- li |> 
  mutate(LensMake = ifelse(LensMake == "NIKON", "Nikon", LensMake)) |> 
  left_join(mapping, by = join_by(LensModel == model_old)) |> 
  mutate(LensModel = ifelse(is.na(model_new), LensModel, model_new), 
         Lens = ifelse(is.na(model_new), LensModel, model_new)) |> 
  mutate(LensInfo = ifelse((is.na(LensInfo) | (LensMake == "Apple")),
                           unlist(Vectorize(create_lensinfo)(LensModel, FALSE)),
                           LensInfo))


# I don't think there is an option in exiftool to update pictures from a list
# of tag values, hence a for loop:
for (i in 1:nrow(modify)){
  this <- modify[i,]
  args <- c(paste0("-LensModel=", this$LensModel),
            paste0("-Lens=", this$Lens),
            paste0("-exif:lensinfo=", this$LensInfo),
            paste0("-xmp:lensinfo=", this$LensInfo),
            paste0("-LensMake=", this$LensMake)
  )
  
  exif_call(args, this$SourceFile)
}


# location information ----------------------------------------------------

# complete the information in the various location tags
# currently for NEF files only
complete_location(imported[grepl(pattern = "*.nef", imported)])


# final cleanup -----------------------------------------------------------

exif_call(args = c("-r", "-delete_original!"), path = imp_path)
