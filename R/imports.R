#' get package imports
#'
#' given a package name, extracts everything from the imports field.
#'
#' @param package the name of the package for the imports
#'
#' @export
#' @importFrom utils packageDescription
#' @return character
get_package_imports = function(package){
  desc = utils::packageDescription(package)

  cat_imports = c(desc$Imports, desc$Depends)
  split_imports = unlist(strsplit(cat_imports, ",", fixed = TRUE))
  split_imports = trimws(grep("^R", gsub("\\n", "", split_imports), invert = TRUE, value = TRUE))
  split_imports = trimws(gsub("\\(.*\\)", "", split_imports))

  return(split_imports)
}
