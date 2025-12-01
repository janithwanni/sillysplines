# test-create_data.R
# WARN: LLM Generated Code

library(jsonlite)

describe("create_data() with piecewise decision boundary", {
  it("generates a data frame with x, y, and class columns", {
    coords <- matrix(c(0.2, 0.3, 0.5, 0.6), ncol = 2, byrow = TRUE)

    df <- create_data(coord = coords, n_samples = 50)

    expect_s3_class(df, "data.frame")
    expect_named(df, c("x", "y", "class"))
    expect_equal(nrow(df), 50)
  })

  it("assigns class = 1 when above boundary and 0 otherwise", {
    coords <- matrix(
      c(
        0.0,
        0.2,
        0.5,
        0.5,
        1.0,
        0.3
      ),
      ncol = 2,
      byrow = TRUE
    )

    set.seed(1)
    df <- create_data(coord = coords, n_samples = 20)

    # Build boundary interpolator manually (same behavior as approxfun)
    boundary_fn <- stats::approxfun(
      x = coords[, 1],
      y = coords[, 2],
      rule = 2
    )

    expected_class <- as.integer(df$y > boundary_fn(df$x))

    expect_identical(df$class, expected_class)
  })

  it("loads coordinate boundaries correctly from a JSON file", {
    tmp <- tempfile(fileext = ".json")

    write_json(
      list(
        c(0.1, 0.3),
        c(0.6, 0.7),
        c(0.9, 0.4)
      ),
      tmp,
      auto_unbox = TRUE
    )

    df <- create_data(coord_filepath = tmp, n_samples = 10)

    expect_s3_class(df, "data.frame")
    expect_equal(nrow(df), 10)
    expect_named(df, c("x", "y", "class"))
  })

  it("produces correct classes for points on known boundary values", {
    coords <- matrix(
      c(
        0.0,
        0.0,
        1.0,
        1.0
      ),
      ncol = 2,
      byrow = TRUE
    )

    # Create points exactly below, on, and above y = x
    df <- data.frame(
      x = c(0.25, 0.50, 0.75),
      y = c(0.20, 0.50, 0.90)
    )

    boundary_fn <- approxfun(coords[, 1], coords[, 2], rule = 2)
    expected <- as.integer(df$y > boundary_fn(df$x))

    # Inject into classification logic using the function
    result <- create_data(coord = coords, n_samples = 0)
    # Overwrite x,y while keeping classification logic
    result <- within(result[rep(1, 3), ], {
      x <- df$x
      y <- df$y
      class <- as.integer(y > boundary_fn(x))
    })

    expect_equal(result$class, expected)
  })

  it("throws an error if both coord and coord_filepath are missing", {
    expect_error(create_data(n_samples = 10))
  })

  it("throws an error if coordinates do not have exactly two columns", {
    bad_coords <- matrix(1:9, 3, 3)
    expect_error(create_data(coord = bad_coords, n_samples = 10))
  })

  it("respects n_samples argument", {
    coords <- matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE)

    df <- create_data(coord = coords, n_samples = 123)

    expect_equal(nrow(df), 123)
  })
})
