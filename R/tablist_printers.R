#' Print a single table from a tablist
#'
#' @param x A table to print
#' @param ... Passed to subsequent methods. A custom `print_fun` (see
#'   `knit_print.tab_list()`) still receives the caption, as a named
#'   `caption` argument there; `print_tabtibble()` itself takes no
#'   `caption` parameter, since the default method never used it (the
#'   caption is applied once, by the surrounding cross-reference wrapper in
#'   `knit_print.tab_list()`, not by the table object itself, so it is not
#'   duplicated in the rendered Typst figure).
#' @export
print_tabtibble <- function(x, ...) {
  UseMethod("print_tabtibble")
}

#' @describeIn print_tabtibble Print a single table from a tablist using the
#'   backend selected by the `tabtibble.backend` option ("markdown"
#'   (default), "tinytable", "gt", or "flextable"; see `render_backend_table()`)
#'   when `x` is a plain data.frame. An `x` that is already a `gt`,
#'   `tinytable`, `flextable`, or `table1` object (see `new_tab_list()`) is
#'   printed via its own `knitr::knit_print()` method instead, regardless of
#'   `tabtibble.backend`, so a table the caller built with a specific
#'   package is rendered exactly as they built it.
#' @param ... Passed to the backend's table constructor
#'   (`knitr::kable()` / `tinytable::tt()` / `gt::gt()` /
#'   `flextable::flextable()`), or to `x`'s own `knit_print()` method.
#' @returns `x`, invisibly
#' @export
print_tabtibble.default <- function(x, ...) {
  if (is.data.frame(x)) {
    render_backend_table(x, ...)
  } else {
    emit_knit_print(x, ...)
  }
  invisible(x)
}
