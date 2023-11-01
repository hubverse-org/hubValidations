# hubValidations 0.0.0.9005

* Improved handling of numeric output type IDs (including high precision floating points / values with trailing zeros), especially when overall hub output type ID column is character. This previously lead to a number of bugs and false validation failures (#58 & #54) which are addressed in this version.

# hubValidations 0.0.0.9004

This release contains a bug fix for reading in and validating CSV column types correctly. (#54) 

# hubValidations 0.0.0.9003

This release includes a number of bug fixes:
- Deployment of custom/optional functions via `validations.yml` can now be accessed directly form `pkg` namespace, addressing bug which required `pkg` library to be loaded. (#51)
- Use `all.equal` to check that sums of `pmf` probabilities equal 1. (#52)

# hubValidations 0.0.0.9002

This release includes improvements designed after the first round of sandbox testing on setting up the CDC FluSight hub. Improvements include:

* Export `parse_file_name` function for parsing model output metadata from a model output file name.
* Issue more specific and informative messaging when `check_tbl_values()` check fails.
* Adding a `verbose` option to `check_for_errors()` function which prints the results of all checks in addition to the deafult overall result and subset of failed checks.

# hubValidations 0.0.0.9001

* Release of first draft `hubValidations` package

# hubValidations 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
