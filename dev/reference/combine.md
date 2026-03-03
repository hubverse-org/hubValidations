# Concatenate validation objects

Combines multiple validation objects of the same class into one. Works
with both single-file validation objects (`hub_validations`,
`target_validations`) and multi-file collection objects
(`hub_validations_collection`, `target_validations_collection`). For
more details on these classes, see [article on `<hub_validations>` S3
class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## Usage

``` r
combine(...)

# S3 method for class 'hub_validations_collection'
combine(...)
```

## Arguments

- ...:

  Validation objects to be concatenated. All objects must be of the same
  class. NULL values are ignored. Empty objects are filtered out when
  combining multiple inputs, but a single empty input is returned as-is.

## Value

An object of the same class as the inputs, or NULL if no valid inputs
provided.

## Details

For `hub_validations` objects, all inputs must share the same `where`
attribute (i.e., be validations for the same subject).

For `hub_validations_collection` objects, the individual
`hub_validations` objects from all collections are extracted and grouped
by their `where` attribute, combining validation results for the same
subject.

Subclasses (e.g., `target_validations`, `target_validations_collection`)
are preserved.

## See also

[`new_hub_validations()`](https://hubverse-org.github.io/hubValidations/dev/reference/new_hub_validations.md),
[`new_hub_validations_collection()`](https://hubverse-org.github.io/hubValidations/dev/reference/new_hub_validations_collection.md),
[`new_target_validations()`](https://hubverse-org.github.io/hubValidations/dev/reference/new_target_validations.md),
[`new_target_validations_collection()`](https://hubverse-org.github.io/hubValidations/dev/reference/new_target_validations_collection.md)
