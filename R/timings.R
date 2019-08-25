#' get timings for dependencies
#'
#' Given a package name, attempts to time how long it takes to load the package
#' via library, and then the time for each of the dependencies. This should
#' provide some estimate of which package might be making your package take
#' a while to load.
#'
#' @param package which package to investigate
#' @param n_rep how many times to do it
#' @param progress should the package be displayed as it's done
#'
#' @details For each of the package and it's imported and dependent packages, the
#'  time required to load the package via `library()` is recorded in a sub-process
#'  (set using `future::plan()`), for the defined number of replicates. Two timings
#'  are recorded, the time to load the package or dependency directly, and then
#'  the time to load the `package` **after** loading the dependency. These are
#'  *pkg* and *after* in the returned data.frame.
#'
#' @export
#' @importFrom microbenchmark microbenchmark
#' @importFrom furrr future_map_dbl
#' @importFrom purrr map map_dbl imap_dfr
#' @importFrom stats median
#' @return data.frame
dependency_timings = function(package, n_rep = 5, progress = TRUE){
  dont_detach = c("methods", "utils")
  imports = get_package_imports(package)
  time_packages = c(package, imports)
  time_packages = time_packages[!(time_packages %in% dont_detach)]

  timings = purrr::map(time_packages, function(ipkg){
    if (progress) {
      message(ipkg)
    }

    pkg_time = purrr::map_dbl(rep(ipkg, n_rep), ~ furrr::future_map_dbl(.x, pkg_timing))
    after_time = purrr::map_dbl(rep(ipkg, n_rep), ~ furrr::future_map_dbl(.x, after_timing, package))
    list(pkg = pkg_time, after = after_time)
  })
  names(timings) = time_packages
  time_df = purrr::imap_dfr(timings, function(.x, .y){
    data.frame(package = .y,
               med = c(stats::median(.x$pkg), stats::median(.x$after)),
               min = c(min(.x$pkg), min(.x$after)),
               max = c(max(.x$pkg), max(.x$after)),
               type = c("pkg", "after"),
               stringsAsFactors = FALSE)
  })
  time_df$which = "other"
  time_df[time_df$package %in% package, "which"] = "self"
  time_df$timings = timings

  return(time_df)
}


pkg_timing = function(pkg){
  requireNamespace("methods")

  time = microbenchmark::microbenchmark(library(pkg, character.only = TRUE), times = 1)
  time$time
}

after_timing = function(pkg1, pkg2){
  requireNamespace("methods")
  library(pkg1, character.only = TRUE)
  time = microbenchmark::microbenchmark(library(pkg2, character.only = TRUE), times = 1)
  time$time
}
