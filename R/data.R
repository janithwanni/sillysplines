# WARN: LLM Generated code
#' Create a 2D Synthetic Dataset With Class Labels
#'
#' Generates a synthetic two-dimensional dataset using random uniform values.
#' Each point is assigned a class label based on whether it lies above all
#' coordinate thresholds provided. Coordinates can be supplied directly as a
#' matrix/data frame or indirectly via a JSON file containing an array of
#' coordinate pairs.
#'
#' @param coord A matrix or data frame with two columns (x and y) specifying
#'   threshold coordinates. Optional if `coord_filepath` is supplied.
#' @param coord_filepath A character string specifying a file path to a JSON
#'   file containing a list/array of coordinate pairs. Optional if `coord` is
#'   supplied.
#' @param n_samples Integer; number of synthetic 2D points to generate.
#'
#' @return A data frame with three columns:
#'   \describe{
#'     \item{x}{Random uniform x-coordinate}
#'     \item{y}{Random uniform y-coordinate}
#'     \item{class}{Binary class label (0 or 1)}
#'   }
#'
#' @details
#' A point is labelled \code{class = 1} if it is above **all** coordinate
#' thresholds such that:
#' \deqn{x > coord[,1] \; \text{and} \; y > coord[,2]}
#'
#' Otherwise, the point is labelled \code{0}.
#'
#' @examples
#' \dontrun{
#' coords <- matrix(c(0.2, 0.3,
#'                    0.4, 0.5,
#'                    0.6, 0.7), ncol = 2, byrow = TRUE)
#'
#' set.seed(1)
#' df <- create_data(coord = coords, n_samples = 500)
#' head(df)
#' }
#'
#' @importFrom jsonlite fromJSON
#' @export
create_data <- function(coord = NULL, coord_filepath = NULL, n_samples = 1000) {
  # Load coordinates from file or object
  if (!is.null(coord_filepath)) {
    if (!file.exists(coord_filepath)) {
      stop("File not found: ", coord_filepath)
    }
    json_txt <- jsonlite::fromJSON(coord_filepath)
    coord <- as.matrix(json_txt)
  } else if (!is.null(coord)) {
    coord <- as.matrix(coord)
  } else {
    stop("Either 'coord' or 'coord_filepath' must be provided.")
  }

  if (ncol(coord) != 2) {
    stop("Coordinates must have exactly two columns (x,y).")
  }

  # Generate dataset
  df <- data.frame(
    x = stats::runif(n_samples, min = min(coord[, 1]), max = max(coord[, 1])),
    y = stats::runif(n_samples, min = min(coord[, 2]), max = max(coord[, 2]))
  )

  # df$class <- classify_points(df$x, df$y, coord)
  # Interpolate boundary y at each x
  # approxfun does piecewise linear interpolation
  boundary_fn <- stats::approxfun(
    x = coord[, 1],
    y = coord[, 2],
    rule = 2 # extend linearly beyond boundary if needed
  )

  # Compute class: above the boundary == 1
  boundary_y <- boundary_fn(df$x)
  df$class <- as.integer(df$y > boundary_y)

  return(df)
}
