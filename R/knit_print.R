#' @importFrom knitr knit_print
#' @export
knitr::knit_print

#' Print a tab_tibble
#'
#' @param x The `tab_tibble` object to print
#' @param ... Passed to subsequent methods
#' @returns `x` invisibly
#' @family knitters
#' @export
knit_print.tab_tibble <- function(x, ...) {
  knit_print(x$table, caption = x$caption, label = x$label, topic_cols = x[["topic_cols"]], ...)
  invisible(x)
}

#' Print a tab_list
#'
#' @details
#' Individual tables are printed with the `print_tabtibble()` S3 generic
#' function. Each table is wrapped in a fenced Div with id `#tbl-<label>`
#' (Quarto's syntax for a crossreferenceable table from computational
#' output), so `@tbl-<label>` resolves and, when the report target is Typst,
#' the table appears in a Typst `#outline(target: figure.where(kind:
#' "quarto-float-tbl"))` (the list of tables; that outline call belongs in
#' the report template, not here). The caption is emitted once, as the
#' Div's trailing paragraph, which Quarto promotes to the figure's caption;
#' it is Typst/Pandoc-escaped (see `escape_typst()`) so caption text
#' containing markup-significant characters renders literally.
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
#' @returns `x` invisibly
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
  if (!identical(knitr::opts_current$get("results"), "asis")) {
    warning("`tab_list` printing usually requires `results='asis'` on the chunk header")
  }
  backend <- getOption("tabtibble.backend", "markdown")
  for (idx in seq_along(x)) {
    if (!is.null(tab_prefix)) {
      cat(tab_prefix)
    }
    if (is.null(print_fun) && identical(backend, "typst") && is.data.frame(x[[idx]])) {
      emit_typst_breakable_figure_rule()
    }
    cat("::: {#tbl-", label[[idx]], "}\n\n", sep = "")
    if (is.null(print_fun)) {
      print_tabtibble(x = x[[idx]], caption = caption[[idx]], topic_cols = topic_cols[[idx]], ...)
    } else {
      print_fun(x = x[[idx]], caption = caption[[idx]], ...)
    }
    cat("\n", escape_typst(as.character(caption[[idx]])), "\n\n:::\n", sep = "")
    if (!is.null(tab_suffix)) {
      cat(tab_suffix)
    }
  }
  invisible(x)
}
