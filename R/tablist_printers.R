#' Print a tablist using `pander::pander()`
#' @param x A table to print
#' @param caption The caption for the table
#' @param ... Passed to `pander::pander`
#' @returns The result of `pander::pander`
#' @export
print_tablist_pander <- function(x, caption, ...) {
  auto_asis_start <- pander::panderOptions("knitr.auto.asis")
  on.exit(pander::panderOptions(knitr.auto.asis = auto_asis_start))
  pander::panderOptions(knitr.auto.asis = FALSE)

  pander::pander(x, caption = caption, ...)
}
