## Resubmission lavaanExtra 0.2.1

0 errors | 0 warnings | 0 notes

## Resubmission lavaanExtra 0.2.0

> Unfortunately, this got stuck in the publication queue. With the old LaTeX version on the CRAN master we cannot build the manual: [...]
> So you use twice an arrow symbol not supported by the old LaTeX. PLease 
replace this and resubmit.

Thank you, I have removed the arrow symbols from the documentation.

## Resubmission lavaanExtra 0.1.9

0 errors | 0 warnings | 0 notes

## Resubmission lavaanExtra 0.1.8

0 errors | 0 warnings | 0 notes

## Resubmission lavaanExtra 0.1.7

0 errors | 0 warnings | 0 notes

## Resubmission lavaanExtra 0.1.6

> Thanks, but without suggested packages installed we still see: * checking tests ... ERROR
You can check yourself by setting the env var _R_CHECK_DEPENDS_ONLY_=true

Thank you, with command `devtools::check(env_vars = c(`_R_CHECK_DEPENDS_ONLY_` = TRUE))`, I was able to fix all problems related to suggested dependencies.

## Resubmission lavaanExtra 0.1.5

> Packages in Suggests should be used conditionally: see 'Writing R Extensions'.
This needs to be corrected even if the missing package(s) become available.
It can be tested by checking with _R_CHECK_DEPENDS_ONLY_=true.

0 errors | 0 warnings | 0 notes

## Resubmission lavaanExtra 0.1.4

0 errors | 0 warnings | 0 notes

## Resubmission lavaanExtra 0.1.3

> Title: Convenience Functions for Package `lavaan`

> Can you pls use undirected quotes on the line above?

* Fixed.

## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.

* There is a note about the doc sub-directory being of more than 1Mb: this is because one of the goals of this package is to produce plots, thus the vignettes include several plots.
