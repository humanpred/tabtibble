#' Print a single table from a tablist
#'
#' @param x A table to print
#' @param caption The caption for the table
#' @param ... Passed to subsequent methods
#' @export
print_tabtibble <- function(x, caption, ...) {
  UseMethod("print_tabtibble")
}

#' @describeIn print_tabtibble Print a single table from a tablist using `pander::pander()`
#' @param ... Passed to `pander::pander`
#' @returns The result of `pander::pander`
#' @export
print_tabtibble.default <- function(x, caption, ...) {
  auto_asis_start <- pander::panderOptions("knitr.auto.asis")
  on.exit(pander::panderOptions("knitr.auto.asis", auto_asis_start))
  pander::panderOptions("knitr.auto.asis", FALSE)
  if (knitr::opts_current$get("results") != "asis") {
    warning("`tab_list` printing usually requires `results='asis'` on the chunk header")
  }

  pander::pander(x, caption = caption, ...)
}
