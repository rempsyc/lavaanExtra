#' @noRd
get_dep_version <- function(dep, pkg = "lavaanExtra") {
  suggests.field <- utils::packageDescription(pkg, fields = "Suggests")
  suggests.list <- unlist(strsplit(suggests.field, ",", fixed = TRUE))
  dep.string <- grep(dep, suggests.list, value = TRUE)
  dep.string <- sub(".*\\((.*?)\\).*", "\\1", dep.string)
  out <- gsub("[^0-9.]+", "", dep.string)
  if (out == "") {
    out <- NULL
  }
  out
}
