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
#' @param type String; How should the points be generated. Can be either 'uniform' or 'grid'
#' @param n_samples Integer; number of synthetic 2D points to generate.
#' @param seed Integer; Random seed to be used for generating dataset
#' @param gap Numeric; Value close to 0 defining gap at the boundary, less than 0.2
#'
#' @return A data frame with three columns:
#'   \describe{
#'     \item{x}{Random uniform x-coordinate}
#'     \item{y}{Random uniform y-coordinate}
#'     \item{class}{Binary class label ("Above" or "Below")}
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
#'
#' coords <- matrix(c(0.2, 0.3,
#'                    0.4, 0.5,
#'                    0.6, 0.7), ncol = 2, byrow = TRUE)
#'
#' df <- create_data(coord = coords, n_samples = 500, seed = 717)
#' head(df)
#'
#'
#' @importFrom jsonlite fromJSON
#' @export
create_data <- function(
  coord_filepath = NULL,
  coord = NULL,
  n_samples = 10000,
  type = "uniform",
  seed = 1835,
  gap = 0
) {
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

  if (gap > 0.2) {
    stop("Assuming the data is scaled between -1, 1, the gap at the boundary should be less than 0.2.")
  }

  min_x <- min(coord[, 1])
  max_x <- max(coord[, 1])
  min_y <- min(coord[, 2])
  max_y <- max(coord[, 2])

  # Generate dataset
  if (type == "uniform") {
    df <- withr::with_seed(
      seed,
      data.frame(
        x = stats::runif(n_samples, min = min_x, max = max_x),
        y = stats::runif(n_samples, min = min_x, max = max_x)
      )
    )
  } else if (type == "grid") {
    df <- expand.grid(
      x = seq(min_x, max_x, length.out = floor(sqrt(n_samples))),
      y = seq(min_y, max_y, length.out = floor(sqrt(n_samples)))
    )
    colnames(df) <- c("x", "y")
  }
  bnd <- classify_boundary(df, coord)
  if (gap > 0) {
    drop_these <- which(abs(bnd$advantage) < gap)
    df$class <- bnd$preds
    df <- df[-drop_these,]
  }
  else
    df$class <- bnd$preds
  return(df)
}

#' Add noise variables to create high-dimensional data
#'
#' This function generates samples from a uniform distribution to be
#' used as noise variables. This can be used to assess the effect of
#' high-dimensions on a model fit, and explainers.
#'
#' @param df A matrix or data frame with three columns (x, y, class).
#' @param n_vars Integer; number of additional variables to generate.
#'
#' @return A data frame with three+n_vars columns, like:
#'   \describe{
#'     \item{x1}{Random uniform coordinate}
#'     \item{x2}{Random uniform coordinate}
#'     \item{x3}{From the original data x}
#'     \item{x4}{From the original data y}
#'     \item{class}{Binary class label ("Above" or "Below")}
#'   }
#'
#' @examples
#'
#' coords <- matrix(c(0.2, 0.3,
#'                    0.4, 0.5,
#'                    0.6, 0.7), ncol = 2, byrow = TRUE)
#'
#' df <- create_data(coord = coords, n_samples = 500, seed = 717)
#'
#' df <- add_noise_vars(df, 2)
#' head(df)
#'
#' @export
add_noise_vars <- function(data, n_vars = 2) {
  n <- nrow(data)
  df <- data.frame(x1 = stats::runif(n,
                                     min(c(data$x, data$y)),
                                     max(c(data$x, data$y))))
  for (i in 2:n_vars)
    df <- cbind(df, stats::runif(n,
                                 min(c(data$x, data$y)),
                                 max(c(data$x, data$y))))
  df <- cbind(df, data)
  colnames(df) <- c(paste0("x", 1:(n_vars+2)), "class")
  return(df)
}

#' Trim data to be have correlated predictors
#'
#' This function removes points outside of a elliptical region
#'
#' @param df A matrix or data frame with three columns (x, y, class).
#' @param r Numeric; Correlation defining the shape, between -1, 1; default 0.6
#'
#' @return A data frame with three+n_vars columns, like:
#'   \describe{
#'     \item{x}{Random uniform coordinate}
#'     \item{y}{Random uniform coordinate}
#'     \item{class}{Binary class label ("Above" or "Below")}
#'   }
#'
#' @examples
#'
#' coords <- matrix(c(0.2, 0.3,
#'                    0.4, 0.5,
#'                    0.6, 0.7), ncol = 2, byrow = TRUE)
#'
#' df <- create_data(coord = coords, n_samples = 500, seed = 717)
#'
#' df <- trim_shape(df)
#' plot(df$x, df$y, col=ifelse(df$class == "Above", "red", "yellow"))
#'
#' @export
trim_shape <- function(data, r = 0.6) {
  n <- nrow(data)

  if (abs(r) > 0.9)
    stop("cor needs to be within (-1, 1).")

  # Data needs to be standardized to make this work
  f_std <- function(x) (x-mean(x))/(sd(x)) # assumes no missings!
  df <- apply(data[,1:2], 2, f_std)
  # Compute mahalanobis distance
  vc <- matrix(c(1, r, r, 1), byrow=TRUE, ncol=2)
  dst <- mahalanobis(df, c(0, 0), vc)

  data <- data[dst<4,]
  return(data)
}
