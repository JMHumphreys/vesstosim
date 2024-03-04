#' Simulate Virus Spread Across Generations
#'
#' This function simulates the spread of a virus across multiple generations,
#' given an initial suitability input (e.g., environmental or demographic factors).
#' It applies both the spreading mechanism and the culling process in each generation.
#'
#' @param gen_n The number of generations to simulate.
#' @param input_r The input suitability raster as a representation of environmental or
#'        demographic factors influencing virus spread.
#' @param n The size of the initial virus pool (default: 500).
#' @param strain_n The number of different virus strains present initially (default: 4).
#' @param mean_dis The mean dispersal distance of the virus during spread simulation
#'        (default: 50).
#' @param R0 The basic reproduction number indicating the average number of cases one
#'        individual can cause in an uninfected population (default: 2).
#' @return A data frame representing the combined data of all generations after the
#'         simulation, with each row corresponding to a surviving viral particle and
#'         including the generation number.
simulate_generations <- function(gen_n, input_r, n = 500, strain_n = 4, mean_dis = 50, R0 = 2, min_cull = 0.2) {
  # gen_n: number of generations to simulate
  # input_r: the input suitability

  all_generations <- data.frame()

  # Initialize the initial pool before the loop starts
  current_pool <- initial_generation(input_r = input_r, n = n, strain_n = strain_n)

  for(i in 1:gen_n){
    # Perform virus spread simulation
    spread_steps <- generation_iterate2(random_points = current_pool,
                                        mean_dis = mean_dis,
                                        R0 = R0,
                                        input_raster = input_r)

    # Record generation number for tracking
    spread_steps$gen <- i

    # Apply culling
    gen_survive <- virus_cull(input_r=input_r, points_df=spread_steps, min_cull = min_cull)

    all_generations <- rbind(all_generations, gen_survive)

    # Update the current_pool
    current_pool <- gen_survive
  }

  return(all_generations)
}
