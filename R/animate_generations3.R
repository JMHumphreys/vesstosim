animate_generations3 <- function(raster_layer, point_data, output_file) {

  # Convert the raster layer to a data.frame
  raster_df <- as.data.frame(raster_layer, xy = TRUE)
  colnames(raster_df) <- c("long", "lat", "value")

  # Identifying a palette with enough distinct colors for each strain
  n_strains <- length(unique(point_data$strain))
  color_palette <- scales::hue_pal()(n_strains)

  # Create the histogram of strains
  histogram_data <- ggplot(data = point_data, aes(x = strain, fill = strain)) +
    geom_bar() +
    scale_fill_manual(values = color_palette) +
    theme_void() + theme(legend.position = "none")

  # Create the base plot with geom_tile for the raster and geom_point for moving points
  p <- ggplot(data = raster_df, aes(x = long, y = lat, fill = value)) +
    geom_raster() +
    geom_point(data = point_data, aes(color = strain, group = interaction(strain, gen))) +
    scale_fill_viridis_c(option = "C") +
    scale_color_manual(values = color_palette) +
    theme_minimal() +
    labs(title = 'Generation: {frame_time}', x = '', y = '') +
    theme(plot.title = element_text(hjust = 0.5)) +
    coord_fixed()

  # Combine the two plots by creating an inset using annotation_custom
  p <- p + annotation_custom(
    ggplotGrob(histogram_data),
    xmin = Inf, xmax = Inf, ymin = -Inf, ymax = Inf
  )

  # Animate the plot
  anim <- gganimate::animate(
    p,
    nframes = 100,
    fps = 10,
    renderer = gganimate::gifski_renderer(output_file)
  )

  # Save the animation
  anim_save(output_file, animation = anim)
}
