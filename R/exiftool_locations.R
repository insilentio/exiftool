# sets iptc and xmp location tags from each other respectively

complete_location <- function(path){
  require("exiftoolr")
  
  req_columns = c("SourceFile", "IPTCDigest",
                  "XMP:City", "IPTC:City",
                  "XMP:State", "IPTC:Province-State", 
                  "XMP:Country", "IPTC:Country-PrimaryLocationName")
  args <- c("-G", "-s",
            paste0("-", req_columns[2]),
            paste0("-", req_columns[3]),
            paste0("-", req_columns[4]),
            paste0("-", req_columns[5]),
            paste0("-", req_columns[6]),
            paste0("-", req_columns[7]))
  locations <- exif_read(args = args, path = path)
  
  # check if one of the desired tags is completely missing and add it if necessary
  missing_col = req_columns[!(req_columns %in% colnames(locations))]
  missing <- as_tibble(matrix(ncol = length(missing_col), nrow = 1, dimnames = list(NULL, missing_col)))
  locations <- locations |> 
    add_column(missing) |>
    select(all_of(req_columns))
  
  # now fill missing cross-value tags, prio is IPTC 
  locations <- locations |> 
    mutate(`XMP:City` = ifelse(!is.na(`IPTC:City`), `IPTC:City`, `XMP:City`)) |> 
    mutate(`XMP:Country` = ifelse(!is.na(`IPTC:Country-PrimaryLocationName`), `IPTC:Country-PrimaryLocationName`, `XMP:Country`)) |> 
    mutate(`XMP:State` = ifelse(!is.na(`IPTC:Province-State`), `IPTC:Province-State`, `XMP:State`)) |> 
    mutate(`IPTC:City` = ifelse(is.na(`IPTC:City`), `XMP:City`, `IPTC:City`)) |> 
    mutate(`IPTC:Province-State` = ifelse(is.na(`IPTC:Province-State`), `XMP:State`, `IPTC:Province-State`)) |> 
    mutate(`IPTC:Country-PrimaryLocationName` = ifelse(is.na(`IPTC:Country-PrimaryLocationName`), `XMP:Country`, `IPTC:Country-PrimaryLocationName`)) |> 
    mutate(IPTCDigest = "-")
  
  # now use the csv option of exifool to handle different values for different files
  # this is much faster than a for loop which calls exiftool every time
  loc_path <- normalizePath('~/Pictures/locations.csv')
  locations |> write_csv(loc_path)
  
  exif_call(args = c("-f", paste0("-csv=", loc_path)), path = path)
}
