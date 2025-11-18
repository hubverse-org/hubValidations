# Get Unique Target Task ID

Retrieves the unique target task ID by extracting all target metadata
and extracting the names of their `target_keys`. For valid config files
these should be the same across all rounds and model tasks.

## Usage

``` r
get_target_task_id(config_tasks)
```

## Arguments

- config_tasks:

  a list representation of the `tasks.json` config file.

## Value

A character vector of unique target task ID names. Post v5.0.0 this
should be a single task ID name.
