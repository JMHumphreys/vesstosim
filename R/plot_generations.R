#' Plot Raster Data with Optional Generational Point Overlays
#'
#' This function takes raster data to plot it and can optionally overlay point data categorized by generations.
#' The raster data is represented using a 'viridis' color scale, and the points are plotted in red if provided,
#' arranged into panels by generations.
#'
#' @param raster_data A Raster* object (RasterLayer, RasterStack, RasterBrick) containing the raster values.
#' @param point_data An optional data frame with columns 'long', 'lat', and 'gen' representing longitude, latitude,
#'                   and generational category respectively. Points will be overlaid on the raster and faceted by 'gen'.
#' @param plot.title A character string to be used as the main title of the plot.
#' @return A ggplot object representing the raster visualization potentially with generational point overlays.
plot_generations <- function(raster_data, point_data = NULL, plot.title = "My Plot Title") {

  raster_df <- as.data.frame(raster_data, xy = TRUE)
  colnames(raster_df) <- c("long", "lat", "value")

  p <- ggplot() +
    geom_raster(data = raster_df, aes(x = long, y = lat, fill = value)) +
    scale_fill_viridis_c(
      name = "Suitability",
      direction = -1,
      limits = c(0, 100)
    ) + # Viridis color scale for raster with fixed limits
    coord_fixed() + # Keep aspect ratio fixed

    # Add labels and title
    labs(
      title = paste0(plot.title),
      x = "Longitude",
      y = "Latitude"
    ) +
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
    )

  # Overlay extant virus points if provided
  if (!is.null(point_data)) {
    p <- p + geom_point(data = point_data, aes(x = long, y = lat), color = "red", size=0.25) +
      facet_wrap(~ gen, ncol = 4)
  }

  return(p)
}
