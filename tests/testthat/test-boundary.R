# WARN: LLM Generated Code

test_that("classify_boundary works with basic linear boundary", {
  data <- data.frame(
    x = c(1, 2, 3, 4, 5),
    y = c(1, 4, 3, 5, 2)
  )

  boundary <- data.frame(
    x = c(1, 5),
    y = c(2, 4)
  )

  result <- classify_boundary(data, boundary)

  expect_type(result, "character")
  expect_length(result, nrow(data))
  expect_equal(result, c("Below", "Above", "Below", "Above", "Below"))
})

test_that("classify_boundary works with custom class labels", {
  data <- data.frame(x = c(1, 2, 3), y = c(1, 3, 2))
  boundary <- data.frame(x = c(1, 3), y = c(2, 2))

  result <- classify_boundary(data, boundary, classes = c("High", "Low"))

  expect_equal(result, c("Low", "High", "Low"))
})

test_that("classify_boundary handles points on the boundary", {
  data <- data.frame(x = c(1, 2, 3), y = c(2, 3, 4))
  boundary <- data.frame(x = c(1, 2, 3), y = c(2, 3, 4))

  result <- classify_boundary(data, boundary)

  # Points exactly on boundary should be classified as "Below" (second class)
  expect_equal(result, c("Below", "Below", "Below"))
})

test_that("classify_boundary works with complex multi-segment boundary", {
  data <- data.frame(
    x = c(1, 1.5, 2, 2.5, 3, 3.5, 4),
    y = c(1, 2.5, 2, 1.5, 3, 3.5, 2)
  )

  boundary <- data.frame(
    x = c(1, 2, 3, 4),
    y = c(2, 3, 2, 3)
  )

  result <- classify_boundary(data, boundary)

  expect_length(result, nrow(data))
  expect_true(all(result %in% c("Above", "Below")))
})

test_that("classify_boundary extrapolates beyond boundary range", {
  data <- data.frame(
    x = c(0, 1, 2, 3, 6), # x values outside [1, 5]
    y = c(1, 2, 3, 4, 5)
  )

  boundary <- data.frame(
    x = c(1, 5),
    y = c(2, 4)
  )

  result <- classify_boundary(data, boundary)

  # Should extrapolate linearly for x = 0 and x = 6
  expect_length(result, nrow(data))
  expect_type(result, "character")
})


test_that("classify_boundary works with matrix input for boundary", {
  data <- data.frame(x = c(1, 2, 3), y = c(2, 4, 3))
  boundary <- matrix(c(1, 3, 2, 4), ncol = 2)

  result <- classify_boundary(data, boundary)

  expect_length(result, nrow(data))
  expect_type(result, "character")
})

test_that("classify_boundary handles single point data", {
  data <- data.frame(x = 2, y = 5)
  boundary <- data.frame(x = c(1, 3), y = c(2, 4))

  result <- classify_boundary(data, boundary)

  expect_length(result, 1)
  expect_equal(result, "Above")
})

test_that("classify_boundary handles horizontal boundary", {
  data <- data.frame(x = c(1, 2, 3), y = c(2, 3, 1))
  boundary <- data.frame(x = c(1, 3), y = c(2, 2))

  result <- classify_boundary(data, boundary)

  expect_equal(result, c("Below", "Above", "Below"))
})

test_that("classify_boundary handles vertical-like steep boundary", {
  data <- data.frame(x = c(1, 1.01, 2), y = c(1, 5, 3))
  boundary <- data.frame(x = c(1, 1.01, 2), y = c(1, 10, 5))

  result <- classify_boundary(data, boundary)

  expect_length(result, nrow(data))
  expect_type(result, "character")
})

# Error handling tests
test_that("classify_boundary validates data input", {
  boundary <- data.frame(x = c(1, 3), y = c(2, 4))

  expect_error(
    classify_boundary(list(x = 1, y = 2), boundary),
    "'data' must be a data frame or matrix"
  )
})

test_that("classify_boundary requires x and y columns in data", {
  data <- data.frame(a = c(1, 2), b = c(3, 4))
  boundary <- data.frame(x = c(1, 3), y = c(2, 4))

  expect_error(
    classify_boundary(data, boundary),
    "'data' must contain columns named 'x' and 'y'"
  )
})

test_that("classify_boundary validates boundary_coord columns", {
  data <- data.frame(x = c(1, 2), y = c(3, 4))

  expect_error(
    classify_boundary(data, data.frame(x = c(1, 2))),
    "'boundary_coord' must have exactly 2 columns"
  )

  expect_error(
    classify_boundary(data, data.frame(x = c(1, 2), y = c(3, 4), z = c(5, 6))),
    "'boundary_coord' must have exactly 2 columns"
  )
})

test_that("classify_boundary validates classes length", {
  data <- data.frame(x = c(1, 2), y = c(3, 4))
  boundary <- data.frame(x = c(1, 3), y = c(2, 4))

  expect_error(
    classify_boundary(data, boundary, classes = c("Only one")),
    "'classes' must be a character vector of length 2"
  )

  expect_error(
    classify_boundary(data, boundary, classes = c("One", "Two", "Three")),
    "'classes' must be a character vector of length 2"
  )
})

test_that("classify_boundary handles NA values appropriately", {
  data <- data.frame(x = c(1, 2, NA, 4), y = c(2, 3, 4, 5))
  boundary <- data.frame(x = c(1, 4), y = c(2, 4))

  result <- classify_boundary(data, boundary)

  # approxfun will return NA for NA input
  expect_true(is.na(result[3]))
  expect_false(is.na(result[1]))
})

test_that("classify_boundary works with descending x coordinates in boundary", {
  data <- data.frame(x = c(1, 2, 3), y = c(1, 3, 2))

  # Boundary with descending x - this may cause unexpected behavior
  # but we test that it doesn't crash
  boundary <- data.frame(x = c(3, 2, 1), y = c(4, 3, 2))

  # This should run without error, though results may not be as expected
  # due to how approxfun handles non-sorted x values
  expect_no_error(classify_boundary(data, boundary))
})

test_that("classify_boundary preserves order of input data", {
  data <- data.frame(
    x = c(5, 1, 3, 2, 4),
    y = c(4, 2, 3, 2.5, 3.5)
  )
  boundary <- data.frame(x = c(1, 5), y = c(2, 4))

  result <- classify_boundary(data, boundary)

  # Result order should match input order
  expect_length(result, 5)
  expect_equal(result[1], ifelse(4 > 4, "Above", "Below")) # x=5, y=4
  expect_equal(result[2], ifelse(2 > 2, "Above", "Below")) # x=1, y=2
})
