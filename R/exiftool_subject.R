library(exiftoolr)
library(tidyverse)


paths <- extract_paths() |> 
  pull(full)

flatten_subject(paths)