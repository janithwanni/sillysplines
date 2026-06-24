# Shiny bindings for sillysplines

Output and render functions for using sillysplines within Shiny
applications and interactive Rmd documents.

## Usage

``` r
sillysplinesOutput(outputId, width = "100%", height = "400px")

renderSillysplines(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- outputId:

  output variable to read from

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- expr:

  An expression that generates an HTML widget (or a
  [promise](https://rstudio.github.io/promises/) of an HTML widget).

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Is `expr` a quoted expression (with
  [`quote()`](https://rdrr.io/r/base/substitute.html))? This is useful
  if you want to save an expression in a variable.

## Examples

``` r
library(shiny)
app <- shinyApp(
  ui = fluidPage(sillysplinesOutput('splines')),
  server = function(input, output) {
    splines_widget <- sillysplines()
    output$splines= renderSillysplines(splines_widget)
  }
)

if (interactive()) app
```
