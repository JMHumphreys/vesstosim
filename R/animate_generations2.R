animate_generations2 <- function(raster_layer, point_data, output_file) {

  raster_df <- as.data.frame(raster_layer, xy = TRUE)
  colnames(raster_df) <- c("long", "lat", "value")

  # Identifying a palette with enough distinct colors for each strain
  n_strains <- length(unique(point_data$strain))
  color_palette <- scales::hue_pal()(n_strains)

  # Create the base plot with geom_tile for the raster and geom_point for moving points
  p <- ggplot() +
    geom_raster(data = raster_df, aes(x = long, y = lat, fill = value)) +
    scale_fill_viridis_c(
      name = "Suitability",
      direction = -1,
      limits = c(0, 100)
    ) +
    geom_point(data = point_data, aes(x = long, y = lat, group = gen, color = strain)) + # Set color as an aesthetic based on strain
    scale_color_manual(values = color_palette) + # Use manual color scaling with our defined palette
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
    labs(title = 'Generation:{frame_time}', x = 'Longitude', y = 'Latitude') +
    coord_fixed() +
    transition_time(gen)

  # Animate and save the file
  gganimate::animate(p, height=600, width=800, nframes = 15, fps = 3, renderer=gganimate::gifski_renderer(output_file))
}
