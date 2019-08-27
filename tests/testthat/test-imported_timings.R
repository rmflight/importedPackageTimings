context("test-imported_timings")

dcf_data = c("callr", "cli", "digest")

test_that("package imports works", {
  devtools_imports = get_imports("devtools")
  devtools_suggests = get_imports("devtools", suggests = TRUE)

  expect_known_output(devtools_imports, "devtools_imports")

  expect_lt(length(devtools_imports), length(devtools_suggests))

  dcf_imports = get_imports("example_dcf.dcf")
  dcf_suggests = get_imports("example_dcf.dcf", suggests = TRUE)

  expect_equal(dcf_imports, dcf_data)
  expect_lt(length(dcf_imports), length(dcf_suggests))
})

test_that("full timing works", {
  timings_devtools = imported_timings("devtools", progress = FALSE)

  expect_known_output(timings_devtools$package, "timings_devtools_packages")

  expect_lt(timings_devtools$med[2], timings_devtools$med[1])
  expect_equal(timings_devtools$type[c(1,2)], c("pkg", "after"))
  expect_equal(timings_devtools$which[1:3], c("self", "self", "import"))
  expect_equal(length(timings_devtools$timings[[1]][[1]]), 5)
})

test_that("direct package list works", {
  timings_single_package = imported_timings("devtools", imports = FALSE, progress = FALSE, n_rep = 1)

  expect_equal(nrow(timings_single_package), 1)
  expect_equal(timings_single_package$package, "devtools")
  expect_equal(length(timings_single_package$timings[[1]][[1]]), 1)

  expect_message(imported_timings("devtools", imports = FALSE, n_rep = 1), "devtools")

  timings_multiple_package = imported_timings(c("devtools", "cli"), progress = FALSE)
  expect_equal(nrow(timings_multiple_package), 2)
  expect_equal(timings_multiple_package$package, c("devtools", "cli"))
})

test_that("list from dcf works", {
  timings_dcf = imported_timings("example_dcf.dcf", progress = FALSE, n_rep = 1)

  expect_equal(nrow(timings_dcf), 3)
})

