Simulated Disease Spread
================

- <a href="#libraries" id="toc-libraries">Libraries</a>
- <a href="#load-example-raster" id="toc-load-example-raster">Load Example
  Raster</a>
- <a href="#prepare-raster" id="toc-prepare-raster">Prepare Raster</a>
- <a href="#main-function" id="toc-main-function">Main Function</a>
- <a href="#simulate-multiple-generations"
  id="toc-simulate-multiple-generations">Simulate Multiple Generations</a>
- <a href="#animated-generation-series"
  id="toc-animated-generation-series">Animated Generation Series</a>
- <a href="#stepwise-demo-of-functions"
  id="toc-stepwise-demo-of-functions">Stepwise Demo of Functions</a>

## Libraries

<details open>
<summary>Hide code</summary>

``` r
library(tidyverse)
library(gganimate)
library(raster)
library(terra)
library(raptr)
library(here)
```

</details>

Load **vesstosim** functions:

<details open>
<summary>Hide code</summary>

``` r
library(vesstosim)
```

</details>

## Load Example Raster

This is a stack with 16 temperature layers derived from MIROC6
(https://wcrp-cmip.org/nodes/miroc/).

<details open>
<summary>Hide code</summary>

``` r
test_r <- rast(here("assets/MIROC6_012222.tif"))[[1]]
test_r
```

</details>

    class       : SpatRaster 
    dimensions  : 450, 900, 1  (nrow, ncol, nlyr)
    resolution  : 4.783622, 7.321982  (x, y)
    extent      : -2041.554, 2263.706, -3114.816, 180.0761  (xmin, xmax, ymin, ymax)
    coord. ref. : +proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=km +no_defs 
    source      : MIROC6_012222.tif 
    name        : MIROC6_012222_1 
    min value   :       -3.635353 
    max value   :        2.123827 

## Prepare Raster

This function strips the geographic projection and optionally scales
values to the 0-100 range required for other functions. This example
raster has a Mercator projection and negative cell values, so it needs
some preprocessing.

<details open>
<summary>Hide code</summary>

``` r
test_r <- prep_raster(test_r, scale=TRUE)
test_r <- aggregate(test_r, fact=2) # more coarse to speed up, more cell = more time
test_r
```

</details>

    class       : SpatRaster 
    dimensions  : 317, 477, 1  (nrow, ncol, nlyr)
    resolution  : 0.1029247, 0.1029247  (x, y)
    extent      : -119.3474, -70.25233, 6.473571, 39.10069  (xmin, xmax, ymin, ymax)
    coord. ref. : +proj=longlat +datum=WGS84 +no_defs 
    source(s)   : memory
    name        : MIROC6_012222_1 
    min value   :        6.819771 
    max value   :       99.825994 

### View Results

<details open>
<summary>Hide code</summary>

``` r
quick_plot <- plot_mappoints(test_r, plot.title = "Fake Suitabilty Model")
quick_plot
```

</details>

![](Demo_files/figure-commonmark/unnamed-chunk-5-1.png)

## Main Function

## Simulate Multiple Generations

Several generations are simulated, each dependent on the previous. May
take a couple minutes…

<details open>
<summary>Hide code</summary>

``` r
spread_sim <- simulate_generations(gen_n = 5,        # Number of generations to simulate 
                                   input_r = test_r,  # Environmental suitability raster
                                   n = 500,           # Initial population size
                                   strain_n = 4,      # number of strains to randomly assign
                                   mean_dis = 50,     # mean virus movement distance (km)
                                   R0 = c(1,3,2,5)    # Reproduction number, mean offspring
                                   )                  # can be unique R0 by strain


dim(spread_sim)
```

</details>

    [1] 58269     5

<details open>
<summary>Hide code</summary>

``` r
range(spread_sim$gen)
```

</details>

    [1] 1 5

<details open>
<summary>Hide code</summary>

``` r
spread_sim %>%
  group_by(strain) %>%
  summarise(Count = length(strain))
```

</details>

    # A tibble: 4 × 2
      strain   Count
      <chr>    <int>
    1 strain.1 50482
    2 strain.2  1038
    3 strain.3  6518
    4 strain.4   231

<details open>
<summary>Hide code</summary>

``` r
head(spread_sim)
```

</details>

      rand.id   strain      lat       long gen
    1     1.1 strain.4 33.11672 -100.38715   1
    2     2.1 strain.3 30.07584  -98.95731   1
    3     2.1 strain.3 29.43842  -99.53995   1
    4     5.1 strain.2 30.99547 -104.01927   1
    5     5.1 strain.2 30.55787 -103.75090   1
    6     5.1 strain.2 30.94391 -104.62480   1

## Animated Generation Series

<details open>
<summary>Hide code</summary>

``` r
animate_generations2(
  raster_layer = test_r, # suitability for map background
  point_data = spread_sim, # data simulated above
  output_file = "./assets/sim_generations.gif" # name for saved gif
)
```

</details>

![](sim_generations.gif)

## Stepwise Demo of Functions

### Generate Initial Virus Locations

Eventually, different strains could be assigned different virulence or
habitat/vector requirements.

<details open>
<summary>Hide code</summary>

``` r
initial_virus <- initial_generation(input_r = test_r, #climate raster for testing
                                    n = 1000,        #number to create
                                    strain_n = 4)    #random strain names


dim(initial_virus)
```

</details>

    [1] 1000    4

<details open>
<summary>Hide code</summary>

``` r
head(initial_virus)
```

</details>

            long      lat rand.id   strain
    1 -102.93091 21.34619       1 strain.2
    2  -98.19637 28.55091       2 strain.3
    3  -96.75543 17.22920       3 strain.2
    4  -95.82911 18.05260       4 strain.2
    5  -88.93315 20.11109       5 strain.3
    6 -104.57770 20.93449       6 strain.2

View Results  
Random assignment but weighted by suitabilty score.

<details open>
<summary>Hide code</summary>

``` r
quick_plot <- plot_mappoints(test_r, initial_virus, "Suitabilty and Initial Points")
quick_plot
```

</details>

![](Demo_files/figure-commonmark/unnamed-chunk-9-1.png)

### Create One New Generations

Movement distance (mean_dis) from source location and the number of
offspring produced (R0) are stochastic.

<details open>
<summary>Hide code</summary>

``` r
virus_spread <- generation_iterate(random_points = initial_virus,
                                   mean_dis = 50, #mean of a normal dist, stochastic distance
                                   R0 = 5, #mean of a poisson dist, stochastic offspring N
                                   input_raster = test_r #suitability grid
                                   )

dim(virus_spread)
```

</details>

    [1] 4693    4

<details open>
<summary>Hide code</summary>

``` r
head(virus_spread) # Note that the rand.id can be traced back to initial point of origin
```

</details>

      rand.id   strain      lat      long
    1     1.1 strain.2 20.89538 -102.9627
    2     1.1 strain.2 21.01431 -102.5992
    3     1.1 strain.2 21.22387 -102.4709
    4     1.1 strain.2 21.28404 -103.4044
    5     1.1 strain.2 21.58438 -102.5155
    6     1.1 strain.2 20.97762 -102.6900

View Results Offspring from initial virus locations.

<details open>
<summary>Hide code</summary>

``` r
quick_plot <- plot_mappoints(test_r, virus_spread, "1st Generation Offspring")
quick_plot
```

</details>

![](Demo_files/figure-commonmark/unnamed-chunk-11-1.png)

### Random Removal

Random extinction and removal. Probability of extinction is related to
environmental suitability but stochastic.

<details open>
<summary>Hide code</summary>

``` r
extant_virus <- virus_cull(input_r=test_r, points_df=virus_spread)

dim(extant_virus)
```

</details>

    [1] 2846    4

<details open>
<summary>Hide code</summary>

``` r
head(extant_virus)
```

</details>

      rand.id   strain      lat      long
    1     1.1 strain.2 20.89538 -102.9627
    2     1.1 strain.2 21.01431 -102.5992
    3     1.1 strain.2 21.22387 -102.4709
    4     1.1 strain.2 21.28404 -103.4044
    5     1.1 strain.2 21.58438 -102.5155
    6     1.1 strain.2 20.97762 -102.6900

View Results  
View first generation offspring after local extinction.

<details open>
<summary>Hide code</summary>

``` r
quick_plot <- plot_mappoints(test_r, extant_virus, "Random Extiction from 1st Generation")
quick_plot
```

</details>

![](Demo_files/figure-commonmark/unnamed-chunk-13-1.png)

### Simulate Multiple Generations

Several generations are simulated, each dependent on the previous. May
take a couple minutes…

<details open>
<summary>Hide code</summary>

``` r
spread_sim <- simulate_generations(gen_n = 5,        # Number of generations to simulate 
                                   input_r = test_r,  # Environmental suitability raster
                                   n = 500,           # Initial population size
                                   strain_n = 4,      # number of strains to randomly assign
                                   mean_dis = 50,     # mean virus movement distance (km)
                                   R0 = 3             # Reproduction number, mean offspring
                                   )


dim(spread_sim)
```

</details>

    [1] 21585     5

<details open>
<summary>Hide code</summary>

``` r
range(spread_sim$gen)
```

</details>

    [1] 1 5

<details open>
<summary>Hide code</summary>

``` r
head(spread_sim)
```

</details>

      rand.id   strain      lat       long gen
    1     1.1 strain.4 35.39683  -97.92594   1
    2     1.1 strain.4 34.82415  -97.84398   1
    3     2.1 strain.2 22.36759  -99.50271   1
    4     2.1 strain.2 22.51907  -99.79097   1
    5     2.1 strain.2 21.71239 -100.14079   1
    6     3.1 strain.1 16.31942  -92.77536   1

View Results  
Panel View of simulation.

<details open>
<summary>Hide code</summary>

``` r
quick_plot <- plot_generations(test_r, spread_sim, "Multiple Generations")
quick_plot
```

</details>

![](Demo_files/figure-commonmark/unnamed-chunk-15-1.png)
