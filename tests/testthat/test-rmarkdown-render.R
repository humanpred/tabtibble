# A real (non-Quarto) rmarkdown::render() to confirm auto-detection --
# not a forced `tabtibble.render_mode` option -- correctly identifies plain
# R Markdown and produces an ordinary captioned table instead of a literal,
# broken `::: {#tbl-...}` div. Slow and requires `rmarkdown` and `pandoc` to
# be installed; skips with a message when they are not, per the package's
# own contract.

skip_rmarkdown_tests <- function() {
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc is not available")
  skip_if(length(find.package("tabtibble", quiet = TRUE)) == 0, "tabtibble is not installed (only load_all()-ed)")
}

render_html <- function(body_lines) {
  dir <- tempfile("tabtibble-rmd-")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  rmd <- file.path(dir, "fixture.Rmd")
  html <- file.path(dir, "fixture.html")
  writeLines(
    c(
      "---",
      "title: Fixture",
      "output: html_document",
      "---",
      "",
      "```{r echo=FALSE}",
      "library(tabtibble)",
      "```",
      "",
      body_lines
    ),
    rmd
  )
  rmarkdown::render(rmd, output_format = "html_document", quiet = TRUE, envir = new.env())
  expect_true(file.exists(html))
  paste(readLines(html, warn = FALSE), collapse = "\n")
}

test_that("a tab_tibble rendered with plain rmarkdown (no Quarto) gets a real caption, not a literal crossref div", {
  skip_rmarkdown_tests()

  txt <- render_html(c(
    "```{r echo=FALSE}",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(data.frame(x = 1:2, y = c('a', 'b'))),",
    "  caption = 'A plain R Markdown caption',",
    "  label = 'rmdfixture'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_match(txt, "A plain R Markdown caption", fixed = TRUE)
  # the div marker never shows up as literal text
  expect_no_match(txt, "::: {#tbl-", fixed = TRUE)
  expect_no_match(txt, ":::<", fixed = TRUE)
})

test_that("a pre-built gt table rendered with plain rmarkdown gets a plain caption paragraph", {
  skip_rmarkdown_tests()
  skip_if_not_installed("gt")

  txt <- render_html(c(
    "```{r echo=FALSE}",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(gt::gt(data.frame(x = 1))),",
    "  caption = 'A prebuilt gt caption',",
    "  label = 'rmdgt'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_match(txt, "A prebuilt gt caption", fixed = TRUE)
  expect_no_match(txt, "::: {#tbl-", fixed = TRUE)
})

test_that("a tab_tibble rendered with real Quarto still gets the crossref div (mode auto-detection, the Quarto side)", {
  skip_quarto_tests()

  txt <- render_typst_pdf(c(
    "```{r echo=FALSE}",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(data.frame(x = 1)),",
    "  caption = 'Auto-detected Quarto caption',",
    "  label = 'autoquarto'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```",
    "",
    "See @tbl-autoquarto for details."
  ))

  expect_match(txt, "Auto-detected Quarto caption", fixed = TRUE)
  expect_match(txt, "Table 1", fixed = TRUE)
})
