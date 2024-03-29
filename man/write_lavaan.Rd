% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_lavaan.R
\name{write_lavaan}
\alias{write_lavaan}
\title{Vector-based lavaan syntax interpreter}
\usage{
write_lavaan(
  mediation = NULL,
  regression = NULL,
  covariance = NULL,
  indirect = NULL,
  latent = NULL,
  intercept = NULL,
  threshold = NULL,
  constraint.equal = NULL,
  constraint.smaller = NULL,
  constraint.larger = NULL,
  custom = NULL,
  label = FALSE,
  use.letters = FALSE
)
}
\arguments{
\item{mediation}{Mediation    indicators (\code{~} symbol: "is regressed on").
Differs from argument \code{regression} because path names
can be optionally specified automatically with argument
\code{label}.}

\item{regression}{Regression indicators (\code{~} symbol: "is regressed on").}

\item{covariance}{(Residual) (co)variance indicators (\verb{~~} symbol:
"is correlated with").}

\item{indirect}{Indirect effect indicators (\verb{:=} symbol: "indirect
effect defined as"). If a named list is provided,
with names "IV" (independent variables), "M" (mediator),
and "DV" (dependent variables), \code{write_lavaan} attempts to
write indirect effects automatically. In this case, the
\code{mediation} argument must be specified too.}

\item{latent}{Latent variable indicators (\verb{=~} symbol: "is measured by").}

\item{intercept}{Intercept indicators (\code{~ 1} symbol: "intercept").}

\item{threshold}{Threshold indicators (\code{|} symbol: "threshold").}

\item{constraint.equal}{Equality indicators (\code{==} symbol).}

\item{constraint.smaller}{Smaller than indicators (\code{<} symbol).}

\item{constraint.larger}{Greater than indicators (\code{>} symbol).}

\item{custom}{Custom specifications. Takes a \emph{single} string just
like regular \code{lavaan} syntax would. Always added at
the end of the model.}

\item{label}{Logical, whether to display path names for the
mediation argument.}

\item{use.letters}{Logical, for the labels, whether to use letters
instead of the variable names.}
}
\value{
A character string, representing the specified \code{lavaan} model.
}
\description{
Vector-based lavaan syntax interpreter.
}
\examples{
\dontshow{if (requireNamespace("lavaan", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
x <- paste0("x", 1:9)
(latent <- list(
  visual = x[1:3],
  textual = x[4:6],
  speed = x[7:9]
))

HS.model <- write_lavaan(latent = latent)
cat(HS.model)

library(lavaan)
fit <- lavaan(HS.model,
  data = HolzingerSwineford1939,
  auto.var = TRUE, auto.fix.first = TRUE,
  auto.cov.lv.x = TRUE
)
summary(fit, fit.measures = TRUE)
\dontshow{\}) # examplesIf}
}
\seealso{
The corresponding vignette: \url{https://lavaanextra.remi-theriault.com/articles/write_lavaan.html}
}
