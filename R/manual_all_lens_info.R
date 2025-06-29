# Update lens information
# 
# generate the lensinfo from manually entered variables
# this info is written into a file (lenses.txt) and can then be used
# by using exiftools -@ parameter function
# writes the various tags for the lens name plus the lensinfo
# (which is used for prime/zoom info)
# 
# BE AWARE: It is very important to generate a proper list of affected files first since the info is
# not generated by metadata but hardcoded -> error prone!!!
source("exiftool_snippets.R")

p1 <- "Apple"
f1 <- "4.25"
f2 <- ""
a1 <- "1.8"
a2 <- ""
p2 <- ""
m <- "Apple"

lens <- paste0(p1, " ", f1, ifelse(f2 != "", paste0("-", f2), ""), "mm f/", a1, ifelse(a2 != "", paste0("-", a2), ""), p2)
info <- paste(f1, ifelse(f2 != "", f2, f1), a1, ifelse(a2 != "", a2, a1))

lenses <- c( 
  (paste0("-lens=", lens)), 
  (paste0("-lensmodel=", lens)), 
  (paste0("-lensid=", lens)), 
  (paste0("-lensinfo=", info)),
  paste0("-lensmake=", m))

tibble(lenses) |> 
  write_csv("~/Pictures/Album/lenses.txt",
            col_names = FALSE)

# read PhotoStatistica exif_export.csv for path creation
paths <- extract_paths()
output_paths(paths)

system("exiftool -@ ~/Pictures/Album/lenses.txt -@ ~/Pictures/paths.txt")
