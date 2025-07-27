# Exifer
<!-- badges: start -->

[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

<!-- badges: end -->

**Various code to handle image metadata**

-   *prepare_import* handles all metadata work after embedding and before exporting in ON1. It uses several subfunctions:

    -   *complete_location* synchronizes IPTC and XMP location info
    -   *flatten_subject* creates flat keywords and subject tags from hierarchical ones
    -   *harmonize_lensinfo* creates harmonized lens model and other lens information based on a mapping table
    -   *create_lensinfo* creates the values for the lens info tag based on lens model, which is used for prime \<-\> zoom differentiation

-   *after_export* handles all metadata work on exported jpg photos from ON1. It uses partially the same subfunctions as above:

    -   *harmonize_lensinfo* creates harmonized lens model and other lens information based on a mapping table
    -   *convert35* adds the 35mm equivalent focal length based on a mapping table

-   *transfer_metadata* allows to find matching photos in different directories; mainly in Export Album compared to original album. Updates the target photos with all metadata from originals.

-   helper functions:

    -   *extract_paths* creates a tibble with file paths from PhotoStatisticas "exif-export.csv"
    -   *output_paths* writes a tibble of paths into a csv file
    -   *handle_return* takes a tibble of metadata information in exiftool compatible format and either writes it to a csv and executes exiftool on top of it or returns the tibble unchanged.

The package relies heavily on the [exiftoolr](https://github.com/JoshOBrien/exiftoolr) package and thereby on the mighty [exiftool](https://exiftool.org) itself.
