
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hubValidations <a href="https://hubverse-org.github.io/hubValidations/"><img src="man/figures/logo.png" align="right" height="131" alt="hubValidations website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/hubverse-org/hubValidations/branch/main/graph/badge.svg)](https://app.codecov.io/gh/hubverse-org/hubValidations?branch=main)
[![R-CMD-check](https://github.com/hubverse-org/hubValidations/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hubverse-org/hubValidations/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of hubValidations is to provide a testing framework for
performing hubverse hub validations.

## Installation

You can install the development version of hubValidations like so:

``` r
remotes::install_github("hubverse-org/hubValidations")
```

> ##### 💡 TIP
>
> `hubValidations` has a dependency on the `arrow` package. For
> troubleshooting `arrow` installation problems, please consult the
> [`arrow` package
> documentation](https://arrow.apache.org/docs/r/#installation).
>
> You could also try installing the package from the [Apache R Universe
> repository](https://apache.r-universe.dev) with:
>
> ``` r
> install.packages("arrow", repos = c("https://apache.r-universe.dev", "https://cran.r-project.org"))
> ```

------------------------------------------------------------------------

## Code of Conduct

Please note that the hubValidations package is released with a
[Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By
contributing to this project, you agree to abide by its terms.

## Contributing

Interested in contributing back to the open-source Hubverse project?
Learn more about how to [get involved in the Hubverse
Community](https://hubdocs.readthedocs.io/en/latest/overview/contribute.html)
or [how to contribute to hubValidations](.github/CONTRIBUTING.md).

### Contributing new check functions

If submitting a new check function, please ensure you update
`inst/check_table.csv` with metadata about the check. See our
[contributing guidelines](.github/CONTRIBUTING.md) for more details.
