# Create a 2D Synthetic Dataset With Class Labels

Generates a synthetic two-dimensional dataset using random uniform
values. Each point is assigned a class label based on whether it lies
above all coordinate thresholds provided. Coordinates can be supplied
directly as a matrix/data frame or indirectly via a JSON file containing
an array of coordinate pairs.

## Usage

``` r
create_data(
  coord_filepath = NULL,
  coord = NULL,
  n_samples = 10000,
  type = "uniform",
  seed = 1835
)
```

## Arguments

- coord_filepath:

  A character string specifying a file path to a JSON file containing a
  list/array of coordinate pairs. Optional if `coord` is supplied.

- coord:

  A matrix or data frame with two columns (x and y) specifying threshold
  coordinates. Optional if `coord_filepath` is supplied.

- n_samples:

  Integer; number of synthetic 2D points to generate.

- type:

  String; How should the points be generated. Can be either 'uniform' or
  'grid'

- seed:

  Integer; Random seed to be used for generating dataset

## Value

A data frame with three columns:

- x:

  Random uniform x-coordinate

- y:

  Random uniform y-coordinate

- class:

  Binary class label (0 or 1)

## Details

A point is labelled `class = 1` if it is above **all** coordinate
thresholds such that: \$\$x \> coord\[,1\] \\ \text{and} \\ y \>
coord\[,2\]\$\$

Otherwise, the point is labelled `0`.

## Examples

``` r

coords <- matrix(c(0.2, 0.3,
                   0.4, 0.5,
                   0.6, 0.7), ncol = 2, byrow = TRUE)

set.seed(1)
df <- create_data(coord = coords, n_samples = 500)
head(df)
#>           x         y class
#> 1 0.5833290 0.2026021 Below
#> 2 0.2218693 0.2220578 Below
#> 3 0.5741707 0.5829402 Below
#> 4 0.5831354 0.5024238 Below
#> 5 0.2361910 0.3709667 Above
#> 6 0.5364458 0.3487250 Below

```
