#' Animate Generational Movement Over a Raster Layer
#'
#' This function creates an animation of point data moving over a raster layer through time, representing
#' different generations. The raster is visualized with a 'viridis' color scale and points are animated
#' over it to show generational changes.
#'
#' @param raster_layer A Raster* object (RasterLayer, RasterStack, RasterBrick) containing the raster values
#'                     to be plotted as the background layer in the animation.
#' @param point_data A data frame containing the coordinates and generations for the points. Must contain
#'                   the columns 'long', 'lat', and 'gen', where 'gen' is used for the animation frames.
#' @param output_file A character string indicating the path and file name for the saved animation file.
#' @return Invisibly returns the animation object created by gganimate::animate().
#'         The animation is also saved as a file specified by `output_file`.
#' @importFrom ggplot2 ggplot geom_raster scale_fill_viridis_c geom_point theme_minimal theme element_text labs coord_fixed
#' @importFrom gganimate animate transition_time gifski_renderer
animate_generations <- function(raster_layer, point_data, output_file) {

  raster_df <- as.data.frame(raster_layer, xy = TRUE)
  colnames(raster_df) <- c("long", "lat", "value")

  # Create the base plot with geom_tile for the raster and geom_point for moving points
  p <- ggplot() +
    geom_raster(data = raster_df, aes(x = long, y = lat, fill = value)) +
    scale_fill_viridis_c(
      name = "Suitability",
      direction = -1,
      limits = c(0, 100)
    ) +
    geom_point(data = point_data, aes(x = long, y = lat, group = gen), color = "red") +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 25),
      axis.title.x = element_text(size = 18),
      axis.title.y = element_text(size = 18),
      legend.title = element_text(face = "bold", size = 16),
      legend.text = element_text(size = 14),
      legend.position = "bottom",
      legend.key.width = unit(1.25, "cm"),
      legend.key.height = unit(0.75, "cm")
    ) +
    labs(title = 'Generation:{frame_time}', x = 'Longitude', y = 'Latitude', fill = "Suitabilty") +
    coord_fixed() +
    transition_time(gen)

   gganimate::animate(p, height=600, width=800, nframes = 15, fps = 3, renderer=gifski_renderer(output_file))
}
