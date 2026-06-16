# sillysplines

The goal of sillysplines is to give you a simple HTMLWidget that can
draw silly little linear splines in an HTML widget and then download the
coordinates to create datasets from.

## Installation

You can install the development version of sillysplines from
[GitHub](https://github.com/) with:

``` r

pak::pak("janithwanni/sillysplines")
```

You can install the CRAN version by running

``` r

install.packages("pak")
```

## Example

You start off by running
[`sillysplines()`](https://janithwanni.github.io/sillysplines/reference/sillysplines.md)
from the package.

``` r

library(sillysplines)
sillysplines()
```

This should open up an HTML widget that shows a box containing an
initial spline design. You can add points by clicking on intermediate
areas, and you can drag points by clicking on the nodes.

Once done you can click Download boundary to get a JSON file containing
the coordinates.

Then it’s a matter of using the create_data function to create a dataset
of your size

``` r

create_data(coord_filepath="<yourfilenamehere.json>", n_samples = 1000)
```
