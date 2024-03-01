#' Generate Initial Points within a Raster Layer
#'
#' This function generates a specified number of random points within the extent of a given raster layer.
#' The raster values are scaled between 0 and 100, with random points geolocated based on cell values.
#' Each point is assigned a unique identifier and a random strain designation from a user-defined range.
#'
#' @param test_r A raster object representing the spatial area and suitability score for point generation.
#' @param n An integer representing the number of random points to generate.
#' @param strain_n An integer representing the number of different strain designations to assign.
#'
#' @return A dataframe of random points with their coordinates, a unique ID, and a strain designation.
#' @export
#'
initial_generation <- function(input_r, n, strain_n) {

  # Generate n number of random points
  random_points_data <- raptr::randomPoints(input_r, n = n, prob = TRUE)
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
