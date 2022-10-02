.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "Suggested citation: Th\u00e9riault, R. (2022).",
    "lavaanExtra: Convenience functions",
    " for lavaan \n(R package version ",
    utils::packageVersion("lavaanExtra"),
    ") [Computer software]. https://lavaanExtra.remi-theriault.com/ "
  )
}
