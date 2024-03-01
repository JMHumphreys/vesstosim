#' Prepares a Raster Object
#'
#' This function reprojects a raster to WGS84 (EPSG:4326) and rescales its cell values to a range of 0 to 100.
#'
#' @param input_raster A SpatRaster object from the terra package representing the raster to be processed.
#'
#' @return A SpatRaster object that has been reprojected and rescaled.
#'
prep_raster <- function(input_raster, scale=TRUE) {

  # Ensure input is a terra Raster object
  if (!inherits(input_raster, "SpatRaster")) {
    stop("Input must be a SpatRaster object from the terra package.")
  }

  # Reproject the raster to long-lat (WGS84; EPSG:4326)
  tmp_raster <- project(input_raster, "+proj=longlat +datum=WGS84")

  if(scale==TRUE){
    # Rescale the cell values to be between 0 and 100
    min_val <- min(values(tmp_raster), na.rm = TRUE)
    max_val <- max(values(tmp_raster), na.rm = TRUE)
    values(tmp_raster) <- (values(tmp_raster) - min_val) / (max_val - min_val) * 100
  }

  # Return the processed raster
  return(tmp_raster)
}
