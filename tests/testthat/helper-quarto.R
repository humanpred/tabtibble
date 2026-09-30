# Shared fixtures for rendering a real Quarto document to a Typst PDF
# (test-quarto-render.R, test-rmarkdown-render.R). Slow and requires Quarto
# (with its bundled Typst) and the `tabtibble` package to be actually
# installed (not just `devtools::load_all()`-ed, since Quarto renders in a
# separate R process -- see `find.package()` below). Tests using these skip
# with a message rather than fail when that environment is not available,
# per the package's own contract.

skip_quarto_tests <- function() {
  skip_if_not_installed("quarto")
  skip_if_not_installed("pdftools")
  skip_if_not(isTRUE(quarto::quarto_available()), "Quarto is not available")
  skip_if(length(find.package("tabtibble", quiet = TRUE)) == 0, "tabtibble is not installed (only load_all()-ed)")
}

# The Typst list-of-tables outline call (`figure.where(kind:
# "quarto-float-tbl")`) is Quarto's own internal kind string for a
# crossreferenceable table from computational output, verified against
# Quarto 1.9.37 + Typst 0.14.2. It is not `figure.where(kind: table)` (the
# native Typst table kind); a future Quarto version could rename it, in
# which case only this test fixture needs updating, not tabtibble's R code,
# which never references that string.
quarto_typst_preamble <- c(
  "---",
  "title: Fixture",
  "format:",
  "  typst:",
  "    toc: false",
  "---",
  "",
  "```{=typst}",
  "#outline(title: [List of Tables], target: figure.where(kind: \"quarto-float-tbl\"))",
  "```",
  "",
  "```{r echo=FALSE}",
  "library(tabtibble)",
  "```"
)

render_typst_pdf_pages <- function(body_lines) {
  dir <- tempfile("tabtibble-quarto-")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  qmd <- file.path(dir, "fixture.qmd")
  pdf <- file.path(dir, "fixture.pdf")
  writeLines(c(quarto_typst_preamble, body_lines), qmd)
  quarto::quarto_render(qmd, output_format = "typst", quiet = TRUE, as_job = FALSE)
  expect_true(file.exists(pdf))
  pdftools::pdf_text(pdf)
}

render_typst_pdf <- function(body_lines) {
  paste(render_typst_pdf_pages(body_lines), collapse = "\n")
}
