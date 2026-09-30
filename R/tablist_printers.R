#' Print a single table from a tablist
#'
#' @param x A table to print
#' @param ... Passed to subsequent methods. A custom `print_fun` (see
#'   `knit_print.tab_list()`) still receives the caption, as a named
#'   `caption` argument there; the `print_tabtibble()` generic itself
#'   takes no `caption` parameter, so calling it directly needs none.
#' @export
print_tabtibble <- function(x, ...) {
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
#'   under R Markdown (see `detect_render_mode()`), `caption` (when
#'   supplied) is still shown for it, as a plain bold paragraph before the
#'   table, since there is no single API across those packages for adding
#'   a caption to an already-built object.
#' @param caption The table's caption, or `NULL` (the default). Under
#'   Quarto, ignored -- the crossref wrapper in `knit_print.tab_list()`
#'   applies it instead, so it is not duplicated in the rendered Typst
#'   figure. Under R Markdown, applied as the table's own caption (see
#'   `render_backend_table()`); `knit_print.tab_list()` always supplies it.
#' @param topic_cols Character vector of column names to group into
#'   repeating topic headers; only used by the `"typst"` backend under
#'   Quarto (see `render_backend_table()`).
#' @param ... Passed to the backend's table constructor
#'   (`knitr::kable()` / `tinytable::tt()` / `gt::gt()` /
#'   `flextable::flextable()`), or to `x`'s own `knit_print()` method.
#' @returns `x`, invisibly
#' @export
print_tabtibble.default <- function(x, caption = NULL, ..., topic_cols = character(0)) {
  if (is.data.frame(x)) {
    render_backend_table(x, topic_cols = topic_cols, caption = caption, ...)
  } else {
    if (!is.null(caption) && identical(detect_render_mode(), "rmarkdown")) {
      cat("**", escape_typst(as.character(caption)), "**\n\n", sep = "")
    }
    emit_knit_print(x, ...)
  }
  invisible(x)
}
