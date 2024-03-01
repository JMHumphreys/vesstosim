#' Plot Raster and Optional Point Data
#'
#' Generates a plot from raster data, optionally overlaying point data on the raster visualization.
#' The raster data is visualized using a `viridis` color scale and the points are plotted in red if provided.
#'
#' @param raster_data A Raster* object (RasterLayer, RasterStack, RasterBrick), with raster values to be visualized.
#' @param point_data An optional data frame containing point coordinates with columns 'long' for longitude and 'lat' for latitude.
#'        If provided, these points will be overlaid on the raster plot.
#' @param plot.title A character string defining the main title of the plot.
#' @return A ggplot object representing the visualized raster data and optional point data overlay.
plot_mappoints <- function(raster_data, point_data = NULL, plot.title = "My Plot Title") {

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
    labs(
      title = paste0(plot.title),
      x = "Longitude",
      y = "Latitude"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title.x = element_text(size = 14),
      axis.title.y = element_text(size = 14)
    )

  # Overlay extant virus points if provided
  if (!is.null(point_data)) {
    p <- p + geom_point(data = point_data, aes(x = long, y = lat), color = "red", size=0.25)
  }

  return(p)
}
