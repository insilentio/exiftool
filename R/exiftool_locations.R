# sets iptc and xmp location tags from each other respectively
# seems to be a problem for ON1 with NEF files, hence the restriction

complete_location <- function(path){
  require("exiftoolr")
  
  paths <- path |> 
    sort()
  
  # first write to xmp tags from iptc if available
  argswrite <- c("-xmp:city<iptc:city") 
  common <- c("-if 'defined $iptc:city'")
  exif_call(args = argswrite, path = paths, common_args = common)
  
  argswrite <- c("-xmp:state<iptc:province-state") 
  common <- c("-if 'defined $iptc:province-state'")
  exif_call(args = argswrite, path = paths, common_args = common)
  
  argswrite <- c("-xmp:country<iptc:Country-PrimaryLocationName") 
  common <- c("-if 'defined $iptc:Country-PrimaryLocationName'")
  exif_call(args = argswrite, path = paths, common_args = common)
  
  # then the other way round if iptc is not already filled
  argswrite <- c("-iptc:city<xmp:city") 
  common <- c("-if 'defined $xmp:city and not defined $iptc:city'")
  exif_call(args = argswrite, path = paths, common_args = common)
  
  argswrite <- c("-iptc:province-state<xmp:state") 
  common <- c("-if 'defined $xmp:state and not defined $iptc:province-state'")
  exif_call(args = argswrite, path = paths, common_args = common)
  
  argswrite <- c("-iptc:Country-PrimaryLocationName<xmp:country") 
  common <- c("-if 'defined $xmp:country and not defined $iptc:Country-PrimaryLocationName'")
  exif_call(args = argswrite, path = paths, common_args = common)
  
  # there is a built-in check for iptc <-> xmp differences
  # to avoid a warning we reset this value
  exif_call(args = "-IPTCDigest=new", path = paths)
}
