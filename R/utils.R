#' @noRd
get_dep_version <- function(dep) {
  suggests.field <- utils::packageDescription("rempsyc", fields = "Suggests")
  suggests.list <- strsplit(suggests.field, ",\n")[[1]]
  dep.string <- grep(dep, suggests.list, value = TRUE)
  dep.string <- sub(".*\\((.*?)\\).*", "\\1", dep.string)
  gsub("[^0-9.]+", "", dep.string)
}
