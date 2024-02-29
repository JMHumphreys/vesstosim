#' Generate Initial Points within a Raster Layer
#'
#' This function generates a specified number of random points within the extent of a given raster layer.
#' The raster values are rescaled between 0 and 100, with random points geolocated based on rescaled values.
#' Each point is assigned a unique identifier and a random strain designation from a user-defined range.
#'
#' @param test_r A raster object representing the spatial area and suitability score for point generation.
#' @param n An integer representing the number of random points to generate.
#' @param strain_n An integer representing the number of different strain designations to assign.
#'
#' @return A dataframe of random points with their coordinates, a unique ID, and a strain designation.
#' @export
#'
#' @examples
#' # Load required packages
#' library(raster)
#' library(raptr)
#'
#' # Create a test raster
#' test_raster <- raster(nrow = 10, ncol = 10)
#' test_raster[] <- runif(ncell(test_raster))
#'
#' # Generate random points
#' random_pts <- initial_generation(test_r = test_raster, n = 50, strain_n = 5)
#' print(random_pts)
#'
initial_generation <- function(test_r, n, strain_n) {
  # Ensure required libraries are loaded
  require(raster)
  require(raptr)

  # Find min and max values
  range_val <- range(values(test_r), na.rm=T)

  # Rescale the values from 0 to 100
  rescaled_raster <- (test_r - range_val[1]) / diff(range_val) * 100

  # Generate n number of random points
  random_points_data <- raptr::randomPoints(rescaled_raster, n = n, prob = TRUE)
  random_points <- as.data.frame(random_points_data)

  # Label coordinates
  names(random_points) <- c("long", "lat")

  # Assign ID number
  random_points$rand.id <- seq_len(n)

  # Randomly assign nominal strain designations
  samp_strains <- paste0("strain.", seq_len(strain_n))
  random_points$strain <- sample(samp_strains, size = n, replace = TRUE)

  # Return the dataframe
  return(random_points)
}
