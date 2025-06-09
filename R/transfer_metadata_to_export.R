path <- "/Volumes/NoBackup/Bilder/Export/Album"
path2 <- "/Users/Daniel/Pictures/Album"

files_from <- tibble(
  path_from = list.files(path2,
                         recursive = TRUE,
                         full.names = TRUE)
) |>
  mutate(match = str_sub(path_from, 1, nchar(path_from) - 4)) 

files <- tibble(
  path_to = list.files(path,
                    recursive = TRUE,
                    full.names = TRUE)
  ) |>
  filter(!(str_ends(path_to, "mov") | str_ends(path_to, "mp4"))) |> 
  mutate(name_to = str_extract(path_to, "[0-9]{4}-.*")) |> 
  mutate(dir_to = str_sub(path_to, 1, nchar(path_to) - nchar(name_to))) |> 
  mutate(name_from = str_remove(name_to, "[0-9]{4}-([0-9]{2}[-_]){5}")) |> 
  mutate(dir_from = str_replace(dir_to, ".*\\/Album", "/Users/Daniel/Pictures/Album")) |> 
  mutate(match = paste0(dir_from, name_from)) |>
  mutate(match = str_sub(match, 1, nchar(match) - 4)) |>
  left_join(files_from, by = "match") |> 
  select(match, path_to, path_from)


for (i in 1:nrow(files)) {
  # args <- c("-all=", "-tagsfromfile", "@", "-icc_profile", "-tagsfromfile", files$path_from[i],
  #           "-exif:all", "-xmp:all", "-iptc:all", "--makernotes:all", "--icc_profile:all", "--on1ref")
  
  args <- c("-exif:all=", "-xmp:all=", "-iptc:all=", "-iptcdigest=", "-tagsfromfile", files$path_from[i],
            "-exif:all", "-xmp:all", "-iptc:all", "--on1ref", "-makernotes:all=")
  
  exif_call(args = args, path = files$path_to[i])
}



files <- tibble(
  path_to = list.files(path,
                       recursive = TRUE,
                       full.names = TRUE)
) |>
  filter(!(str_ends(path_to, "mov") | str_ends(path_to, "mp4"))) |> 
  mutate(name_to = str_extract(path_to, "[0-9]{4}-.*")) |> 
  mutate(dir_to = str_sub(path_to, 1, nchar(path_to) - nchar(name_to))) |> 
  mutate(name_from = str_remove(name_to, "[0-9]{4}-([0-9]{2}[-_]){5}")) |> 
  mutate(dir_from = str_replace(dir_to, ".*\\/Album", "/Users/Daniel/Pictures/Album")) |> 
  mutate(match = paste0(dir_from, name_from)) |>
  mutate(match = str_sub(match, 1, nchar(match) - 4)) |> 
  anti_join(files_from, by = "match") |> 
  select(path_to)
