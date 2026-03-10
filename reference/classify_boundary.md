# Classify Points Relative to a Boundary Line

Classifies data points as being above or below a boundary defined by a
set of coordinates. The function uses piecewise linear interpolation to
determine the boundary's y-value at each x-coordinate in the data, then
classifies points based on whether they lie above or below this
boundary.

## Usage

``` r
classify_boundary(data, boundary_coord, classes = c("Above", "Below"))
```

## Arguments

- data:

  A data frame containing at least two columns named 'x' and 'y'
  representing the coordinates of points to be classified.

- boundary_coord:

  A two-column matrix or data frame where the first column contains
  x-coordinates and the second column contains y-coordinates defining
  the boundary line. Points should be ordered by x-coordinate for proper
  interpolation.

- classes:

  A character vector of length 2 specifying the class labels. Default is
  `c("Above", "Below")`. The first element is assigned to points above
  the boundary, the second to points below.

## Value

A character vector of the same length as the number of rows in `data`,
containing class labels for each point.

## Details

The function uses
[`stats::approxfun()`](https://rdrr.io/r/stats/approxfun.html) with
`rule = 2` for piecewise linear interpolation. This means:

- Between boundary points, linear interpolation is used

- For x-values outside the range of boundary coordinates, the boundary
  is extrapolated linearly using the slope at the nearest endpoint

Points exactly on the boundary (y == boundary_y) are classified as
"Below" (the second class).

## See also

[`approxfun`](https://rdrr.io/r/stats/approxfun.html) for details on
interpolation

## Examples

``` r
# Create sample data
data <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 4, 3, 5, 1)
)

# Define a simple linear boundary
boundary <- data.frame(
  x = c(1, 5),
  y = c(2, 4)
)

# Classify points
classify_boundary(data, boundary)
#> [1] "Below" "Above" "Below" "Above" "Below"

# Use custom class labels
classify_boundary(data, boundary, classes = c("High", "Low"))
#> [1] "Low"  "High" "Low"  "High" "Low" 

# Complex boundary with multiple segments
boundary_complex <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(1, 3, 2, 4, 3)
)
classify_boundary(data, boundary_complex)
#> [1] "Above" "Above" "Above" "Above" "Below"
```
