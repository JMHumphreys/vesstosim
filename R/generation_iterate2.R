generation_iterate2 <- function(random_points, mean_dis, R0, input_raster) {
  # Determine if R0 is a single value or a list/vector
  if(length(R0) > 1) {
    # Check if the number of R0 values matches the number of unique strains
    if(length(R0) != length(unique(random_points$strain))) {
      stop("The length of R0 does not match the number of unique strains.")
    }

    # Create a named vector with R0 values for each strain
    R0_values <- setNames(R0, unique(random_points$strain))
  } else {
    # If R0 is a single value, create a named vector where all strains have the same R0
    R0_values <- setNames(rep(R0, length(unique(random_points$strain))), unique(random_points$strain))
  }

  # Create an empty data frame to store all generated points
  all_generated_points <- data.frame(rand.id = integer(), strain = character(),
                                     lat = numeric(), long = numeric())

  # Iterate over each row in the random_points data frame
  for (i in 1:nrow(random_points)) {
    # Extract original coordinates and other information
    lat <- random_points[i, "lat"]
    long <- random_points[i, "long"]
    rand_id <- random_points[i, "rand.id"] + 0.1 # unique, traceable id
    strain <- random_points[i, "strain"]

    # Draw the number of points to generate from the Poisson distribution using the R0 for the specific strain
    gen_x <- rpois(1, lambda = R0_values[strain])
    gen_x <- ifelse(gen_x == 0, 1, gen_x) # virus extinction is performed in a separate function

    # Initialize a temporary data frame to store generated points for this iteration
    temp_points <- data.frame(rand.id = rep(rand_id, gen_x), strain = rep(strain, gen_x),
                              lat = numeric(gen_x), long = numeric(gen_x))

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
  library(raster)
  all_generated_points$raster_value <- extract(input_raster, all_generated_points[, c("long", "lat")])[,1]
  all_generated_points <- all_generated_points[!is.na(all_generated_points$raster_value),]
  all_generated_points[,"raster_value"] <- NULL

  return(all_generated_points)
}
