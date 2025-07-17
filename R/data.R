#' Crop Factor data
#'
#' data describes the crop factor of cameras and smartphones
#' this is needed to compute the 35mm equivalent focal length
#'
#' @format a csv file yielding a data frame
#' \describe{
#'   \item{model}{the camera model (exif data)}
#'   \item{lensmodel}{the lens model (exif data), only for smartphone cameras relevant and NA for all else}
#'   \item{factor}{the crop factor (focal length times crop factor yields the 35mm equivalent focal length)}
#' }
#' @source self produced based on exif data
"cropFactor"


#' Lens mapping data
#'
#' data describes the the mapping from unharmonized camera names to harmonized names
#'
#' @format a csv file yielding a data frame
#' \describe{
#'   \item{model_old}{the old/original camera model name (exif data)}
#'   \item{model_new}{the new, harmonized camera model name}
#' }
#' @source self produced based on exif data
"lensMapping"