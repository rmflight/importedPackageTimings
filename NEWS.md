# importedPackageTimings 0.0.2

* Added a `NEWS.md` file to track changes to the package.
* `imported_timings` gained two new arguments:
  * `imports` to decide if you actually want to time just the package or the package and it's imports
  * `suggests` to decide if you also want to time packages listed in the Suggests field
* `imported_timings` can now take one of:
  * the name of an installed package to time (the original idea)
    * this will time the installed package and it's imports
  * the name of an installed package to time only (set `imports = FALSE`)
  * a character vector of package names to time directly (`imports` will be disabled automatically)
  * a path to a DCF (i.e. DESCRIPTION) formatted file with fields for Depends, Imports, and Suggests to take the packages to be timed from
* testing added
* code coverage added

# importedPackageTimings 0.0.1

* Initial release!
