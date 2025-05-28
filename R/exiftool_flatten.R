# write flat keywords and subject tags derived from hierarchical ones
# Only writes the lowest level keywords!
flatten_subject <- function(paths){
  argsread <- c("-hierarchicalsubject")
  
  for (i in 1:length(paths)) {
    kw <- exif_call(
      args = argsread,
      path = paths[i],
      common_args = "-s",
      quiet = TRUE)
    
    split <- gsub(".*\\: ", "", kw) |> 
      str_split(", ") |> 
      unlist() |> 
      trimws() |> 
      str_extract("([^\\|]+)$") |> 
      as_tibble() |> 
      distinct(value) |> 
      pull(value)
    
    if (length(split) > 0) {
      argswrite <- c(paste0("-subject=", split),
                     paste0("-keywords=", split)) 
      
      exif_call(args = argswrite, path = paths[i])
    }
  }
}