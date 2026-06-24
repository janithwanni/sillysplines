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
#' @return Returns an `htmlwidgets::shinyWidgetOutput` to be used within the UI
#' of a shiny app.
#'
#' @rdname sillysplines-shiny
#'
#' @export
#' @examplesIf rlang::is_installed(c("shiny"))
#' library(shiny)
#' app <- shinyApp(
#'   ui = fluidPage(sillysplinesOutput('splines')),
#'   server = function(input, output) {
#'     splines_widget <- sillysplines()
#'     output$splines= renderSillysplines(splines_widget)
#'   }
#' )
#'
#' \donttest{if (interactive()) app}
sillysplinesOutput <- function(outputId, width = '100%', height = '400px') {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    'sillysplines',
    width,
    height,
    package = 'sillysplines'
  )
}

#' Connect sillysplines with the sillysplinesOutput
#'
#' @param expr An expression that generates an HTML widget (or a
#'   [promise](https://rstudio.github.io/promises/) of an HTML widget).
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#'  @return Returns a `htmlwidgets::shinyRenderWidget` to be used in the server section
#'  of a shiny app to connect the `sillysplinesOutput` defined above.
#'
#' @rdname sillysplines-shiny
#' @export
renderSillysplines <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, sillysplinesOutput, env, quoted = TRUE)
}
