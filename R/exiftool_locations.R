
# sets iptc and xmp location tags from each other respectively
# seems to be a problem for ON1 with NEF files, hence the restriction


path <- '/Users/Daniel/Pictures/Album/2024/22 - Weihnachten'
paths <- list.files(path,
           recursive = TRUE,
           full.names = TRUE,
           pattern = "*.nef") |> 
  sort()

argswrite <- c("-xmp:city<iptc:city") 
common <- c("-if 'defined $iptc:city'")
exiftoolr::exif_call(args = argswrite, path = paths, common_args = common)

argswrite <- c("-xmp:state<iptc:province-state") 
common <- c("-if 'defined $iptc:province-state'")
exiftoolr::exif_call(args = argswrite, path = paths, common_args = common)

argswrite <- c("-xmp:country<iptc:Country-PrimaryLocationName") 
common <- c("-if 'defined $iptc:Country-PrimaryLocationName'")
exiftoolr::exif_call(args = argswrite, path = paths, common_args = common)


argswrite <- c("-iptc:city<xmp:city") 
common <- c("-if 'defined $xmp:city and not defined $iptc:city'")
exiftoolr::exif_call(args = argswrite, path = paths, common_args = common)

argswrite <- c("-iptc:province-state<xmp:state") 
common <- c("-if 'defined $xmp:state and not defined $iptc:province-state'")
exiftoolr::exif_call(args = argswrite, path = paths, common_args = common)

argswrite <- c("-iptc:Country-PrimaryLocationName<xmp:country") 
common <- c("-if 'defined $xmp:country and not defined $iptc:Country-PrimaryLocationName'")
exiftoolr::exif_call(args = argswrite, path = paths, common_args = common)
