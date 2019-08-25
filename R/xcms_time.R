#' Timings for xcms dependencies
#'
#' A dataset containing the `library(pkg)` timings for the dependencies of
#' the `xcms` package.
#'
#' @format A data frame with 26 rows and 7 variables:
#' \describe{
#'   \item{package}{which package it is}
#'   \item{med}{median timings in microseconds}
#'   \item{min}{minimum load time in microseconds}
#'   \item{max}{maximum load time}
#'   \item{type}{load time for the dependency (pkg), or for the package after loading the dependency (after)}
#'   \item{which}{the package or a dependency}
#'   \item{timings}{the raw times for each replicate}
#' }
#' @source Rober M Flight on personal machine
"xcms_time"
