% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lavaan_reg.R
\name{lavaan_reg}
\alias{lavaan_reg}
\title{Extract relevant regression indices from lavaan model}
\usage{
lavaan_reg(fit, nice_table = FALSE, ...)
}
\arguments{
\item{fit}{lavaan fit object to extract fit indices from}

\item{nice_table}{Logical, whether to print the table as a
\code{rempsyc::nice_table} as well as print the
reference values at the bottom of the table.}

\item{...}{Arguments to be passed to \code{rempsyc::nice_table}}
}
\value{
A dataframe, including the outcome, predictor, standardized
regression coefficient, and corresponding p-value.
}
\description{
Extract relevant regression indices from lavaan model through
\code{lavaan::parameterEstimates} with \code{standardized = TRUE}. In this
case, the beta (B) represents the resulting \code{std.all} column.
}
\examples{
(latent <- list(visual = paste0("x", 1:3),
                textual = paste0("x", 4:6),
                speed = paste0("x", 7:9)))

(regression <- list(ageyr = c("visual", "textual", "speed"),
                    grade = c("visual", "textual", "speed")))

HS.model <- write_lavaan(latent = latent, regression = regression)
cat(HS.model)

library(lavaan)
fit <- lavaan(HS.model, data=HolzingerSwineford1939,
              auto.var=TRUE, auto.fix.first=TRUE,
              auto.cov.lv.x=TRUE)
lavaan_reg(fit)
}
\keyword{CFA}
\keyword{analysis}
\keyword{equation}
\keyword{lavaan}
\keyword{modeling}
\keyword{path}
\keyword{structural}
