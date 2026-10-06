# tabtibble 0.0.2.9000

* The `"typst"` backend frames each table's data with a rule under the
  column header (repeated with the header on every page) and one at the end
  of the table. Attributes on a table adjust it further:
  `tabtibble_header_cols` (the number of leading columns that label their
  rows, separated from the rest by a vertical rule), `tabtibble_widths`
  (Typst column widths, such as `"auto"`, `"3cm"`, or `"2fr"`),
  `tabtibble_topic_labels` (`TRUE` shows each topic header as
  "<column name>: <value>"), and `tabtibble_typst_raw` (columns whose cells
  are Typst markup, such as `$r^2$`, written without escaping).
* `knit_print()` now detects whether it is rendering under Quarto or plain
  R Markdown/knitr (`knitr::opts_knit$get("quarto.version")`, falling back
  to the `QUARTO_PROJECT_ROOT`/`QUARTO_DOCUMENT_PATH` environment
  variables). Under Quarto, behavior is unchanged: each table keeps its
  crossref div (the `"typst"` backend only makes sense there, and now
  falls back to the `"markdown"` backend outside Quarto). Under plain R
  Markdown, that div is skipped -- rendered by plain Pandoc it would show
  up as literal, uncaptioned text -- and each table instead gets an
  ordinary caption the output target understands: `knitr::kable()`'s own
  `caption` for the markdown backend (in its native format for the
  detected target -- `detect_output_target()` reports `"typst"`,
  `"latex"`, `"html"`, `"docx"`, or `"other"` -- rather than always a
  Markdown pipe table), or `tinytable`/`gt`/`flextable`'s own captioning.
  This keeps older Rmd reports working. New `tabtibble.render_mode` and
  `tabtibble.output_target` options force the detected mode/target
  (mainly for tests, or when detection is wrong for some environment).
* `knit_print()` no longer requires `results='asis'` on the chunk header.
  By default (`tabtibble.knitr.auto.asis`, `TRUE`), the rendered markdown
  is returned as `knitr::asis_output()` -- the same mechanism pander uses
  for its `knitr.auto.asis` option -- so knitr inserts it directly whatever
  the chunk's `results` setting. Set `options(tabtibble.knitr.auto.asis =
  FALSE)` to go back to writing directly with `cat()` (which does need
  `results='asis'`, and warns when it is missing).
* **Breaking:** `print_tabtibble()`'s S3 generic no longer declares a
  `caption` formal, so calling it directly needs none; the default method
  still accepts `caption` (now defaulting to `NULL`) for the R Markdown
  mode captioning above. A custom `print_fun` passed to
  `knit_print.tab_list()` still receives the caption as before; if you
  wrote a `print_tabtibble` method expecting a required `caption` formal
  with no default, give it a default instead.
* `new_tab_tibble()` gains an optional `label` column (a Quarto label,
  without the `tbl-` prefix). When absent, a stable label is derived from
  each table's caption, so re-rendering a report reproduces the same
  labels.
* `knit_print.tab_tibble()` / `knit_print.tab_list()` now wrap each table in
  a fenced Div (`::: {#tbl-<label>} ... :::`) so `@tbl-<label>` resolves and,
  for a Quarto report rendered with the Typst PDF engine, the table appears
  in a Typst list of tables (`#outline(target: figure.where(kind:
  "quarto-float-tbl"))`).
* New `tabtibble.backend` option selects how a plain data.frame table is
  rendered: `"markdown"` (the default, via `knitr::kable()`, no extra
  dependency), `"tinytable"`, `"gt"`, `"flextable"`, or `"typst"`. A table
  already built with one of those packages, or with `table1`, is printed via
  its own `knit_print()` method regardless of the option. A missing backend
  package raises a classed `tabtibble_missing_package` condition.
* New `"typst"` backend, and a `topic_cols` column on `new_tab_tibble()`,
  reproduce LaTeX's TopicLongTable natively in Typst: a table sorted by one
  or more "topic" columns (for example subject, then analyte) prints each
  topic value once, as a group header above its rows, and the column header
  and current topic repeat at the top of each page the group continues onto
  (Typst's own `table.header(level = ...)`, verified against the installed
  Typst 0.14.2). `new_tab_tibble()` validates that `topic_cols` names real
  columns and that the table is already sorted by them. Column alignment
  defaults to right for numeric columns and left otherwise, overridable with
  a `tabtibble_align` attribute on the table. The other backends ignore
  `topic_cols`, so its columns just repeat their values on every row.
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
