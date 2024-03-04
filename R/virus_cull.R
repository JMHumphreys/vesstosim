#' Virus Population Culling Based on Raster Data
#'
#' This function performs culling of a virus population based on raster data values
#' that represent probabilities of extinction. Given a set of points and associated raster,
#' it extracts the raster values at each point's location, converts these into probabilities
#' of survival, and then determines whether each virus particle survives.
#'
#' @param input_r A RasterLayer object containing values used to determine the probability
#'        of virus particle extinction. High raster values indicate a higher chance of
#'        surviving whereas lower values indicate higher chances of extinction.
#' @param points_df A data frame of virus particles with columns for longitude ('long') and
#'        latitude ('lat') representing their geographic locations.
#' @return A data frame containing only the points that have survived (not culled),
#'         with the 'decisions' column removed.
virus_cull <- function(input_r, points_df, min_cull) {

  points_vect <- vect(points_df, geom=c("long", "lat"), crs="", keepgeom=TRUE)

  # Find min and max values
  range_val <- range(values(input_r), na.rm=T)

  # Extract raster values corresponding to the points
  points_vect[["extinct_prob"]] <- extract(input_r, points_vect)[,names(input_r)]

  # Inverse of raster value, convert to probability range
  points_vect[["extinct_prob"]] <- (100 - points_vect[["extinct_prob"]])/100

  # Apply the minimum culling threshold (ensuring extinct_prob is not less than min_cull)
  points_vect[["extinct_prob"]] <- pmax(points_vect[["extinct_prob"]], min_cull)


  # Make a random decision based on extinct_prob for each point
  points_df$decisions <- runif(nrow(points_vect)) < points_vect$extinct_prob

  # Keep only the points that were not 'extinct'
  #extant_points <- points_df %>% filter(decisions == FALSE)
  extant_points <- points_df %>% filter(is.na(decisions) == FALSE)

  extant_points[,"decisions"] <- NULL

  return(extant_points)
}
