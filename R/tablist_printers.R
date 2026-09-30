#' Print a single table from a tablist
#'
#' @param x A table to print
#' @param caption The caption for the table. Unused by the default method:
#'   the caption is applied once by the surrounding cross-reference wrapper
#'   in `knit_print.tab_list()`, not by the table object itself, so it is
#'   not duplicated in the rendered Typst figure. Available to a custom
#'   `print_fun` (see `knit_print.tab_list()`) that wants it for another
#'   purpose.
#' @param ... Passed to subsequent methods
#' @export
print_tabtibble <- function(x, caption, ...) {
  UseMethod("print_tabtibble")
}

#' @describeIn print_tabtibble Print a single table from a tablist using the
#'   backend selected by the `tabtibble.backend` option ("markdown"
#'   (default), "tinytable", "gt", "flextable", or "typst"; see
#'   `render_backend_table()`) when `x` is a plain data.frame. An `x` that
#'   is already a `gt`, `tinytable`, `flextable`, or `table1` object (see
#'   `new_tab_list()`) is printed via its own `knitr::knit_print()` method
#'   instead, regardless of `tabtibble.backend`, so a table the caller
#'   built with a specific package is rendered exactly as they built it;
#'   under R Markdown (see `detect_render_mode()`), `caption` is still
#'   shown for it, as a plain bold paragraph before the table, since there
#'   is no single API across those packages for adding a caption to an
#'   already-built object.
#' @param topic_cols Character vector of column names to group into
#'   repeating topic headers; only used by the `"typst"` backend under
#'   Quarto (see `render_backend_table()`).
#' @param ... Passed to the backend's table constructor
#'   (`knitr::kable()` / `tinytable::tt()` / `gt::gt()` /
#'   `flextable::flextable()`), or to `x`'s own `knit_print()` method.
#' @returns `x`, invisibly
#' @export
print_tabtibble.default <- function(x, caption, ..., topic_cols = character(0)) {
  if (is.data.frame(x)) {
    render_backend_table(x, topic_cols = topic_cols, caption = caption, ...)
  } else {
    if (identical(detect_render_mode(), "rmarkdown")) {
      cat("**", escape_typst(as.character(caption)), "**\n\n", sep = "")
    }
    emit_knit_print(x, ...)
  }
  invisible(x)
}
