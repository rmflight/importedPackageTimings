#' get imported packages
#'
#' given a package name, extracts everything from the *Imports* and *Depends*
#' fields.
#'
#' @param package the name of the package for the imports
#' @param suggests should the packages in suggests be returned (default = FALSE)
#'
#' @export
#' @importFrom utils packageDescription
#' @return character
get_imports = function(package, suggests = FALSE){
  if (file.exists(package)) {
    tmp = read.dcf(package)
    desc = list(Imports = tmp[1, "Imports"], Depends = tmp[1, "Depends"])
    if (suggests && ("Suggests" %in% colnames(tmp))) {
      desc$Suggests = tmp[1, "Suggests"]
    }
  } else {
    desc = utils::packageDescription(package)
  }

  cat_imports = c(desc$Imports, desc$Depends)
  if (!is.null(desc$Suggests) && suggests) {
    cat_imports = c(cat_imports, desc$Suggests)
  }
  split_imports = unlist(strsplit(cat_imports, ",", fixed = TRUE))
  split_imports = trimws(grep("^R", gsub("\\n", "", split_imports), invert = TRUE, value = TRUE))
  split_imports = trimws(gsub("\\(.*\\)", "", split_imports))
  names(split_imports) = NULL

  return(split_imports)
}
