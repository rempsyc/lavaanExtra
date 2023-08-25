#' @noRd
get_dep_version <- function(dep, pkg = utils::packageName()) {
  suggests_field <- utils::packageDescription(pkg, fields = "Suggests")
  suggests_list <- unlist(strsplit(suggests_field, ",", fixed = TRUE))
  out <- lapply(dep, function(x) {
    dep_string <- grep(x, suggests_list, value = TRUE, fixed = TRUE)
    dep_string <- dep_string[which.min(nchar(dep_string))]
    dep_string <- unlist(strsplit(dep_string, ">", fixed = TRUE))
    gsub("[^0-9.]+", "", dep_string[2])
  })
  unlist(out)
}
