#' Virus Generation Iteration Function
#'
#' This function takes a set of points, each representing a virus particle, and simulates
#' the spread from each of these points according to a Poisson distribution defined by
#' the basic reproduction number R0. It also accounts for mean dispersal distance to
#' determine new point locations and ensures that generated points over non-eligible areas
#' (e.g., water) are removed.
#'
#' @param random_points A data frame containing points representing individual virus
#'        particles with latitude, longitude, unique identifiers, and strains.
#' @param mean_dis The mean dispersal distance that new points should be generated at,
#'        drawn from a normal distribution.
#' @param R0 The basic reproduction number per particle, controlling the expected number
#'        of new virus particles generated.
#' @param input_raster A raster layer providing spatial context for the simulation,
#'        used to remove generated points that fall onto non-eligible cells like water.
#' @return A data frame of all newly generated points for this iteration, excluding those
#'         generated over non-eligible areas, with latitude and longitude coordinates,
#'         identifiers, and associated virus strains.
generation_iterate <- function(random_points, mean_dis, R0, input_raster) {
  # Create an empty data frame to store all generated points
  all_generated_points <- data.frame(rand.id = integer(), strain = character(),
                                     lat = numeric(), long = numeric())

  # Iterate over each row in the random_points data frame
  for (i in 1:nrow(random_points)) {
    # Extract original coordinates and other information
    lat <- random_points[i, "lat"]
    long <- random_points[i, "long"]
    rand_id <- random_points[i, "rand.id"] + 0.1 #unique, traceable id
    strain <- random_points[i, "strain"]

    # Draw the number of points to generate from the Poisson distribution
    gen_x <- rpois(1, lambda = R0)
    gen_x <- ifelse(gen_x == 0, 1, gen_x) # virus extinction is perfomed in a seperate function

    # Initialize a temporary data frame to store generated points for this iteration
    temp_points <- data.frame(rand.id = integer(gen_x), strain = character(gen_x),
                              lat = numeric(gen_x), long = numeric(gen_x))

    # Fill in the rand.id and strain for temp_points
    temp_points[ , "rand.id"] <- rep(rand_id, gen_x)
    temp_points[ , "strain"] <- rep(strain, gen_x)

    # Generate each point
    for (j in 1:gen_x) {
      # Draw a random distance from the normal distribution
      dis <- rnorm(1, mean = mean_dis)

      # Convert distance to degrees
      km_per_degree <- 111
      dis_deg <- dis / km_per_degree

      # Random bearing in radians
      theta <- runif(1, min = 0, max = 2 * pi)

      # Calculate displacement
      delta_lat <- dis_deg * cos(theta)
      delta_long <- dis_deg * sin(theta) / cos(lat * pi/180)

      # New coordinates
      temp_points[j, "lat"] <- lat + delta_lat
      temp_points[j, "long"] <- long + delta_long
    }

    # Append generated points with corresponding rand.id and strain to the all_generated_points data frame
    all_generated_points <- rbind(all_generated_points, temp_points)
  }

  # Remove points over NA cell values (water)
  all_generated_points$raster_value <- extract(input_raster, all_generated_points[, c("long", "lat")])[,names(input_raster)]
  all_generated_points <- all_generated_points[!is.na(all_generated_points$raster_value),]
  all_generated_points[,"raster_value"] <- NULL

  return(all_generated_points)
}
