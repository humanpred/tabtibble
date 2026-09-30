# Validate and normalize a `topic_cols` list column against its tables

Validate and normalize a `topic_cols` list column against its tables

## Usage

``` r
validate_topic_cols(tables, topic_cols)
```

## Arguments

- tables:

  A `tab_list` (or plain list of tables).

- topic_cols:

  A list the same length as `tables`, or `NULL` (treated as all-empty).

## Value

A list the same length as `tables`, each element a (possibly empty)
character vector, validated against its table.
