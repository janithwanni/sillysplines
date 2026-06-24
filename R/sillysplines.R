#' Create a box to draw silly spline
#'
#' This creates a simple htmlwidget to be used
#'
#' @param width width of container in pixels
#' @param height height of container in pixels
#' @param elementId The id to be used for the container element
#'
#' @import htmlwidgets
#'
#' @export
#' @examplesIf interactive()
#'  sillysplines()
sillysplines <- function(
  width = 640,
  height = 640,
  elementId = "app"
) {
  # forward options using x
  x = list(
    target = elementId,
    props = list(
      width = width,
      height = height,
      elementId = elementId,
      # TODO: Not yet implemented
      lowerRegionColor = "lightblue",
      lowerRegionOpacity = 0.5,
      upperRegionColor = "lightcoral",
      upperRegionOpacity = 0.5
    )
    # TODO: Future props to add
    # lower region color, opacity
    # upper region color, opacity
    # spline color, stroke-width
    # point color, radius, toAnimate, highlightColor
    # showDownload
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
