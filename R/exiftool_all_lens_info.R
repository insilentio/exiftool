# read PhotoStatistica exif_export.csv for path creation
source("exiftool_snippets.R")
paths <- extract_paths()
output_paths(paths)

# then generate the lensinfo from manually entered variables

p1 <- "Canon EF-S"
f1 <- "60"
f2 <- ""
a1 <- "2.8"
a2 <- ""
p2 <- " Macro"

lens <- paste0(p1, " ", f1, ifelse(f2 != "", paste0("-", f2), ""), "mm f/", a1, ifelse(a2 != "", paste0("-", a2), ""), p2)
info <- paste(f1, ifelse(f2 != "", f2, f1), a1, ifelse(a2 != "", a2, a1))

lenses <- c( 
  (paste0("-lens=", lens)), 
  (paste0("-lensmodel=", lens)), 
  (paste0("-lensid=", lens)), 
  (paste0("-lensinfo=", info)))

tibble(lenses) |> 
  write_csv("~/Pictures/Album/lenses.txt",
            col_names = FALSE)


system("exiftool -@ ~/Pictures/Album/lenses.txt -@ ~/Pictures/Album/paths.txt")
