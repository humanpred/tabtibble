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
  knit_print(x$table, caption = x$caption, ...)
  invisible(x)
}

#' Print a tab_list
#'
#' @details
#' Individual tables are printed with the `print_tabtibble()` S3 generic
#' function.
#'
#'
#' @param x The `tab_list` object to print
#' @param ... passed to `print_fun`
#' @param caption The caption for each table as a character vector
#' @param print_fun Override the default printing using `print_tabtibble`. If
#'   provided it is a function taking arguments of `x` (one data.frame to
#'   print), `caption` (the caption for that data.frame), and `...`.
#' @param tab_prefix,tab_suffix Any text to add before/after each figure (`NULL`
#'   to omit)
#' @returns `x` invisibly
#' @family knitters
#' @export
knit_print.tab_list <- function(x, ..., caption, print_fun = NULL, tab_prefix = NULL, tab_suffix = "\n\n") {
  stopifnot(length(x) == length(caption))
  for (idx in seq_along(x)) {
    if (!is.null(tab_prefix)) {
      cat(tab_prefix)
    }
    if (is.null(print_fun)) {
      print_tabtibble(x = x[[idx]], caption = caption[[idx]], ...)
    } else {
      print_fun(x = x[[idx]], caption = caption[[idx]], ...)
    }
    if (!is.null(tab_suffix)) {
      cat(tab_suffix)
    }
  }
  invisible(x)
}
