# WARN: LLM Generated Code

#' Classify Points Relative to a Boundary Line
#'
#' @description
#' Classifies data points as being above or below a boundary defined by a set
#' of coordinates. The function uses piecewise linear interpolation to determine
#' the boundary's y-value at each x-coordinate in the data, then classifies
#' points based on whether they lie above or below this boundary.
#'
#' @param data A data frame containing at least two columns named 'x' and 'y'
#'   representing the coordinates of points to be classified.
#' @param boundary_coord A two-column matrix or data frame where the first
#'   column contains x-coordinates and the second column contains y-coordinates
#'   defining the boundary line. Points should be ordered by x-coordinate for
#'   proper interpolation.
#' @param classes A character vector of length 2 specifying the class labels.
#'   Default is `c("Above", "Below")`. The first element is assigned to points
#'   above the boundary, the second to points below.
#'
#' @return A character vector of the same length as the number of rows in
#'   `data`, containing class labels for each point.
#'
#' @details
#' The function uses `stats::approxfun()` with `rule = 2` for piecewise linear
#' interpolation. This means:
#' \itemize{
#'   \item Between boundary points, linear interpolation is used
#'   \item For x-values outside the range of boundary coordinates, the boundary
#'         is extrapolated linearly using the slope at the nearest endpoint
#' }
#'
#' Points exactly on the boundary (y == boundary_y) are classified as "Below"
#' (the second class).
#'
#' @examples
#' # Create sample data
#' data <- data.frame(
#'   x = c(1, 2, 3, 4, 5),
#'   y = c(2, 4, 3, 5, 1)
#' )
#'
#' # Define a simple linear boundary
#' boundary <- data.frame(
#'   x = c(1, 5),
#'   y = c(2, 4)
#' )
#'
#' # Classify points
#' classify_boundary(data, boundary)
#'
#' # Use custom class labels
#' classify_boundary(data, boundary, classes = c("High", "Low"))
#'
#' # Complex boundary with multiple segments
#' boundary_complex <- data.frame(
#'   x = c(1, 2, 3, 4, 5),
#'   y = c(1, 3, 2, 4, 3)
#' )
#' classify_boundary(data, boundary_complex)
#'
#' @seealso \code{\link[stats]{approxfun}} for details on interpolation
#'
#' @export
classify_boundary <- function(
  data,
  boundary_coord,
  classes = c("Above", "Below")
) {
  # Validate inputs
  if (!is.data.frame(data) && !is.matrix(data)) {
    stop("'data' must be a data frame or matrix")
  }

  if (!all(c("x", "y") %in% names(data))) {
    stop("'data' must contain columns named 'x' and 'y'")
  }

  if (ncol(boundary_coord) != 2) {
    stop("'boundary_coord' must have exactly 2 columns")
  }

  if (length(classes) != 2) {
    stop("'classes' must be a character vector of length 2")
  }

  # Interpolate boundary y at each x
  # approxfun does piecewise linear interpolation
  boundary_fn <- stats::approxfun(
    x = boundary_coord[, 1],
    y = boundary_coord[, 2],
    rule = 2 # extend linearly beyond boundary if needed
  )

  # Compute class: above the boundary == first class
  boundary_y <- boundary_fn(data$x)
  preds <- ifelse(data$y > boundary_y, classes[1], classes[2])

  return(preds)
}
