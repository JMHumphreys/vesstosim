generation_iterate <- function(random_points, mean_dis, mean_poi) {
  # Create an empty data frame to store all generated points
  all_generated_points <- data.frame(rand.id = integer(), strain = character(),
                                     lat = numeric(), long = numeric())

  # Iterate over each row in the random_points data frame
  for (i in 1:nrow(random_points)) {
    # Extract original coordinates and other information
    lat <- random_points[i, "lat"]
    long <- random_points[i, "long"]
    rand_id <- random_points[i, "rand.id"]
    strain <- random_points[i, "strain"]

    # Draw the number of points to generate from the Poisson distribution
    gen_x <- rpois(1, lambda = mean_poi)

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

  return(all_generated_points)
}
