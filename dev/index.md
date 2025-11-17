# hubValidations

The goal of hubValidations is to provide a testing framework for
performing hubverse hub validations.

## Installation

### Latest

You can install the [latest version of hubValidations from the
R-universe](https://hubverse-org.r-universe.dev/hubValidations):

``` r
install.packages("hubValidations", repos = c("https://hubverse-org.r-universe.dev", "https://cloud.r-project.org"))
```

### Development

If you want to test out new features that have not yet been released,
you can install the development version of hubValidations from
[GitHub](https://github.com/) with:

``` r
remotes::install_github("hubverse-org/hubValidations")
```

> \[!NOTE\]
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
[Contributor Code of
Conduct](https://hubverse-org.github.io/hubValidations/dev/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.

## Contributing

Interested in contributing back to the open-source Hubverse project?
Learn more about how to [get involved in the Hubverse
Community](https://hubverse.io/community/) or [how to contribute to
hubValidations](https://hubverse-org.github.io/hubValidations/dev/CONTRIBUTING.md).

### Contributing new check functions

If submitting a new check function, please ensure you update
`inst/check_table.csv` with metadata about the check. See our
[contributing
guidelines](https://hubverse-org.github.io/hubValidations/dev/CONTRIBUTING.md)
for more details.
