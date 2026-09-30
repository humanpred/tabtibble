# Derive a stable Quarto label from a caption

Combines a slugified caption with a short deterministic hash of the full
caption text, so re-rendering the same caption always produces the same
label (no randomness), while two different captions that slugify the
same way (or a caption with no alphanumeric characters) still get
distinct, non-empty labels.

## Usage

``` r
derive_label(caption)
```

## Arguments

- caption:

  A character scalar.

## Value

A character scalar: a valid label without the `tbl-` prefix.
