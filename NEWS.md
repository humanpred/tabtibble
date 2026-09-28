# tabtibble (development version)

* `new_tab_tibble()` gains an optional `label` column (a Quarto label,
  without the `tbl-` prefix). When absent, a stable label is derived from
  each table's caption, so re-rendering a report reproduces the same
  labels.
* `knit_print.tab_tibble()` / `knit_print.tab_list()` now wrap each table in
  a fenced Div (`::: {#tbl-<label>} ... :::`) so `@tbl-<label>` resolves and,
  for a Quarto report rendered with the Typst PDF engine, the table appears
  in a Typst list of tables (`#outline(target: figure.where(kind:
  "quarto-float-tbl")))`).
* New `tabtibble.backend` option selects how a plain data.frame table is
  rendered: `"markdown"` (the default, via `knitr::kable()`, no extra
  dependency), `"tinytable"`, `"gt"`, or `"flextable"`. A table already
  built with one of those packages, or with `table1`, is printed via its own
  `knit_print()` method regardless of the option. A missing backend package
  raises a classed `tabtibble_missing_package` condition.
* `new_tab_list()` now also accepts `gt`, `tinytable`, and `flextable`
  objects that were already built (previously only data.frame-like and
  `table1` objects).
* Caption and cell text containing Typst-significant characters (`* _ # @ $
  < > \` [ ]` or a backslash) are now escaped so they render literally in a
  Typst report.
* `print_tabtibble.default()` no longer uses `pander`; `pander` has been
  dropped from Suggests.

# tabtibble 0.0.1

* Initial CRAN submission.
