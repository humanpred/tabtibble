#' Print a tablist using `pander::pander()`
#' @param name description
print_tablist_pander <- function(x, caption, ...) {
  auto_asis_start <- pander::panderOptions("knitr.auto.asis")
  on.exit(pander::panderOptions(knitr.auto.asis = auto_asis_start))
  pander::panderOptions(knitr.auto.asis = FALSE)

  pander::pander(x, caption = caption)
}
