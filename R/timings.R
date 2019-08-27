#' get timings for imports
#'
#' Given a package name, attempts to time how long it takes to load the package
#' via library, and then the time for each of the imported packages (see \code{\link{get_imports}}).
#' This should provide some estimate of which package might be making your package take
#' a while to load.
#'
#' @param package which package to investigate
#' @param imports should the imports be timed too (default = TRUE)
#' @param suggests should the packages in suggests be added (default = FALSE)
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
#'  You can also run library timings for lists of packages directly, which may be
#'  more useful to quickly narrow down issues with imported timings. This can
#'  be via a character list of packages, or reading from a DESCRIPTION type file.
#'
#' @examples
#' \dontrun{
#' # not run
#' library(importedPackageTimings)
#' library(furrr)
#' plan(multiprocess)
#'
#' # normal running for an installed package
#' devtools_time = imported_timings("devtools")
#'
#' # run the suggested packages too
#' devtools_suggests = imported_timings("devtools", suggests = TRUE)
#'
#' # time particular packages
#' only_devtools = imported_timings("devtools", imports = FALSE)
#' particular_packages = imported_timings(c("cli", "rlang"))
#' }
#'
#' @export
#' @importFrom microbenchmark microbenchmark
#' @importFrom furrr future_map_dbl
#' @importFrom purrr map map_dbl imap_dfr
#' @importFrom stats median
#' @importFrom utils installed.packages
#' @return data.frame
imported_timings = function(package, imports = TRUE, suggests = FALSE, n_rep = 5, progress = TRUE){
  installed_packages = rownames(utils::installed.packages())
  if ((length(package) > 1) || !imports) {
    time_packages = package[package %in% installed_packages]
    do_after = FALSE
  } else {
    imports = get_imports(package, suggests)
    if (package %in% installed_packages) {
      time_packages = c(package, imports)
      do_after = TRUE
    } else {
      time_packages = imports
      do_after = FALSE
    }
  }

  dont_detach = c("methods", "utils")
  time_packages = time_packages[!(time_packages %in% dont_detach)]

  timings = purrr::map(time_packages, function(ipkg){
    if (progress) {
      message(ipkg)
    }

    pkg_time = purrr::map_dbl(rep(ipkg, n_rep), ~ furrr::future_map_dbl(.x, pkg_timing))
    if (do_after) {
      after_time = purrr::map_dbl(rep(ipkg, n_rep), ~ furrr::future_map_dbl(.x, after_timing, package))
    } else {
      after_time = 0
    }

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
  if (!do_after) {
    time_df = time_df[!(time_df$type %in% "after"), ]
  }
  time_df$which = "import"
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
