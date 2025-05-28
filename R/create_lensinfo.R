# generate the lens info (for zoom or prime) from the lensmodel
# format is: min focal range, max focal range, min aperture # min range, min aperture @ max range
# for primes, V2 and V4 are identical to V1 and V3 respectively

create_lensinfo <- function(lensmodel, as_tags = TRUE){
  typenew = as.data.frame(
    stringr::str_remove(lensmodel, ".* (?=[0-9.]{1,5}mm)") |> 
    stringr::str_extract_all("[0-9.]{1,5}", simplify = TRUE))
  
  # build proper format
  info <- (if (ncol(typenew) == 2) {
    typenew |> 
      mutate(V3 = V1, V4 = V2) |> 
      mutate(V5 = paste(V1, V3, V2, V4)) 
  } else if (ncol(typenew) == 3) {
    typenew |> 
      mutate(V4 = V3) |> 
      mutate(V5 = paste(V1, V2, V3, V4)) 
  } else if (ncol(typenew) == 4) {
    typenew |> 
      mutate(V5 = paste(V1, V2, V3, V4)) 
  }) |> 
    select(5) |> 
    pull()
  
  # prepare the lens tag
  lenses <- c(paste0("-exif:lensinfo=", info),
              paste0("-xmp:lensinfo=", info))

  if (as_tags)
    lenses
  else
    info
}
