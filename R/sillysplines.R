#' Create a box to draw silly spline
#'
#' This creates a simple htmlwidget to be used
#'
#' @param initial The initial set of coordinates used to draw the spline, needs to be sorted by x axis
#' @param width width of container in pixels
#' @param height height of container in pixels
#' @param elementId The id to be used for the container element
#'
#' @import htmlwidgets
#'
#' @export
sillysplines <- function(
  initial,
  width = NULL,
  height = NULL,
  elementId = NULL
) {
  # forward options using x
  x = list(
    message = initial
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'sillysplines',
    x,
    width = width,
    height = height,
    package = 'sillysplines',
    elementId = elementId
  )
}

#' Shiny bindings for sillysplines
#'
#' Output and render functions for using sillysplines within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a sillysplines
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name sillysplines-shiny
#'
#' @export
sillysplinesOutput <- function(outputId, width = '100%', height = '400px') {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    'sillysplines',
    width,
    height,
    package = 'sillysplines'
  )
}

#' @rdname sillysplines-shiny
#' @export
renderSillysplines <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, sillysplinesOutput, env, quoted = TRUE)
}

sillysplines_html <- function(...) {
  htmltools::tags$div(
    ...,
    id = "app",
    style = "display: flex; justify-content: center; align-items: center; width: 50%; flex-direction: column;"
  )
}
