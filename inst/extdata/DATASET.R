## code to prepare datasets (for data folder) goes here

cropFactor <- readr::read_csv("data-raw/cropFactor.csv")
usethis::use_data(cropFactor, overwrite = TRUE)
rm(cropFactor)

lensMapping <- readr::read_csv("data-raw/lensMapping.csv")
usethis::use_data(lensMapping, overwrite = TRUE)
rm(lensMapping)
