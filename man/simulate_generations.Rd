% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulate_generations.R
\name{simulate_generations}
\alias{simulate_generations}
\title{Simulate Virus Spread Across Generations}
\usage{
simulate_generations(
  gen_n,
  input_r,
  n = 500,
  strain_n = 4,
  mean_dis = 50,
  R0 = 2
)
}
\arguments{
\item{gen_n}{The number of generations to simulate.}

\item{input_r}{The input suitability raster as a representation of environmental or
demographic factors influencing virus spread.}

\item{n}{The size of the initial virus pool (default: 500).}

\item{strain_n}{The number of different virus strains present initially (default: 4).}

\item{mean_dis}{The mean dispersal distance of the virus during spread simulation
(default: 50).}

\item{R0}{The basic reproduction number indicating the average number of cases one
individual can cause in an uninfected population (default: 2).}
}
\value{
A data frame representing the combined data of all generations after the
        simulation, with each row corresponding to a surviving viral particle and
        including the generation number.
}
\description{
This function simulates the spread of a virus across multiple generations,
given an initial suitability input (e.g., environmental or demographic factors).
It applies both the spreading mechanism and the culling process in each generation.
}
