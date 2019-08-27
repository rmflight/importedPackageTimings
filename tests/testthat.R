library(testthat)
library(importedPackageTimings)
library(furrr)
plan(multiprocess)

test_check("importedPackageTimings")
