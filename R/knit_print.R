#' @importFrom knitr knit_print
#' @export
knitr::knit_print

#' Print a tab_tibble
#'
#' @param x The `tab_tibble` object to print
#' @param ... Passed to subsequent methods
#' @returns The result of `knit_print(x$table, ...)`: by default (see
#'   `knit_print.tab_list()`) a `knitr::asis_output()` value, so a chunk
#'   printing a `tab_tibble` needs no `results='asis'`.
#' @family knitters
#' @export
knit_print.tab_tibble <- function(x, ...) {
  knit_print(x$table, caption = x$caption, label = x$label, topic_cols = x[["topic_cols"]], ...)
}

#' Print a tab_list
#'
#' @details
#' Individual tables are printed with the `print_tabtibble()` S3 generic
#' function. Under Quarto (see `detect_render_mode()`), each table is
#' wrapped in a fenced Div with id `#tbl-<label>` (Quarto's syntax for a
#' crossreferenceable table from computational output), so `@tbl-<label>`
#' resolves and, when the report target is Typst, the table appears in a
#' Typst `#outline(target: figure.where(kind: "quarto-float-tbl"))` (the
#' list of tables; that outline call belongs in the report template, not
#' here). The caption is emitted once, as the Div's trailing paragraph,
#' which Quarto promotes to the figure's caption; it is Typst/Pandoc-escaped
#' (see `escape_typst()`) so caption text containing markup-significant
#' characters renders literally.
#'
#' Under plain R Markdown, that Div is skipped: rendered by plain Pandoc
#' (no Quarto filter to interpret it), it would show up as a literal,
#' uncaptioned wrapper rather than a table figure. Instead, each table
#' carries an ordinary caption the output target understands -- see
#' `render_backend_table()` -- so a report that never used Quarto keeps
#' working exactly as it did before crossref support was added.
#'
#' By default (the `tabtibble.knitr.auto.asis` option, `TRUE`), the
#' rendered markdown is captured and returned as `knitr::asis_output()`,
#' the same mechanism pander uses for its `knitr.auto.asis` option: knitr
#' inserts an asis-classed return value into the document directly,
#' whatever the chunk's own `results` setting, so a chunk printing a
#' `tab_tibble`/`tab_list` needs no `results='asis'` chunk option. Set
#' `options(tabtibble.knitr.auto.asis = FALSE)` to opt out and go back to
#' writing directly with `cat()` (requiring `results='asis'`, with a
#' warning when it is missing) -- useful if something downstream needs to
#' see the literal `cat()` side effect rather than a returned value.
#'
#' @param x The `tab_list` object to print
#' @param ... passed to `print_fun`
#' @param caption The caption for each table as a character vector
#' @param label Character vector of Quarto labels (without the `tbl-`
#'   prefix), one per table, matching `x` in length. `NULL` (the default)
#'   derives a label from each caption via `derive_label()`.
#' @param topic_cols A list the same length as `x`, each element a character
#'   vector of column names to group into repeating topic headers (used
#'   only by the `"typst"` backend; see `render_backend_table()`); `NULL`
#'   (the default) is treated as an empty vector for every table. Before a
#'   table using the `"typst"` backend, a Typst rule allowing its figure to
#'   break across pages is emitted ahead of the table's own crossref div --
#'   see `emit_typst_breakable_figure_rule()`.
#' @param print_fun Override the default printing using `print_tabtibble`. If
#'   provided it is a function taking arguments of `x` (one data.frame to
#'   print), `caption` (the caption for that data.frame), and `...`.
#' @param tab_prefix,tab_suffix Any text to add before/after each figure (`NULL`
#'   to omit)
#' @returns With `tabtibble.knitr.auto.asis` `TRUE` (the default), a
#'   `knitr::asis_output()` character value holding the rendered markdown.
#'   With it `FALSE`, `x` invisibly (the markdown is written with `cat()`
#'   as a side effect instead).
#' @family knitters
#' @export
knit_print.tab_list <- function(x, ..., caption, label = NULL, topic_cols = NULL, print_fun = NULL, tab_prefix = NULL, tab_suffix = "\n\n") {
  stopifnot(length(x) == length(caption))
  if (is.null(label)) {
    label <- vapply(caption, derive_label, character(1))
  } else {
    stopifnot(length(x) == length(label))
  }
  if (anyDuplicated(label)) {
    stop("`label` values must be unique.", call. = FALSE)
  }
  if (is.null(topic_cols)) {
    topic_cols <- replicate(length(x), character(0), simplify = FALSE)
  } else {
    stopifnot(length(x) == length(topic_cols))
  }

  render <- function() {
    backend <- getOption("tabtibble.backend", "markdown")
    mode <- detect_render_mode()
    for (idx in seq_along(x)) {
      if (!is.null(tab_prefix)) {
        cat(tab_prefix)
      }
      if (identical(mode, "quarto")) {
        if (is.null(print_fun) && identical(backend, "typst") && is.data.frame(x[[idx]])) {
          emit_typst_breakable_figure_rule()
        }
        cat("::: {#tbl-", label[[idx]], "}\n\n", sep = "")
      }
      if (is.null(print_fun)) {
        print_tabtibble(x = x[[idx]], caption = caption[[idx]], topic_cols = topic_cols[[idx]], ...)
      } else {
        print_fun(x = x[[idx]], caption = caption[[idx]], ...)
      }
      if (identical(mode, "quarto")) {
        cat("\n", escape_typst(as.character(caption[[idx]])), "\n\n:::\n", sep = "")
      }
      if (!is.null(tab_suffix)) {
        cat(tab_suffix)
      }
    }
  }

  if (isTRUE(getOption("tabtibble.knitr.auto.asis", TRUE))) {
    text <- paste(utils::capture.output(render()), collapse = "\n")
    return(knitr::asis_output(text))
  }

  if (!identical(knitr::opts_current$get("results"), "asis")) {
    warning(
      "`tab_list` printing usually requires `results='asis'` on the chunk header, ",
      "unless `options(tabtibble.knitr.auto.asis = TRUE)` (the default) is set"
    )
  }
  render()
  invisible(x)
}
