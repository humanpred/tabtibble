# These tests render a real Quarto document to a Typst PDF and check the
# rendered text, which is slow and requires Quarto (with its bundled Typst)
# and the `tabtibble` package to be actually installed (not just
# `devtools::load_all()`-ed, since Quarto renders in a separate R process --
# see `find.package()` below). They skip with a message rather than fail
# when that environment is not available, per the package's own contract.

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

test_that("a tab_tibble renders to Typst with the caption in the List of Tables and a working @tbl- crossref", {
  skip_quarto_tests()

  txt <- render_typst_pdf(c(
    "```{r echo=FALSE}",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(data.frame(x = 1:2, y = c('a', 'b'))),",
    "  caption = 'A fixture table caption',",
    "  label = 'fixture'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```",
    "",
    "See @tbl-fixture for details."
  ))

  expect_match(txt, "List of Tables", fixed = TRUE)
  expect_match(txt, "A fixture table caption", fixed = TRUE)
  # the crossref resolved to "Table 1", not a literal "?@tbl-fixture"
  expect_match(txt, "Table 1", fixed = TRUE)
  expect_no_match(txt, "@tbl-fixture", fixed = TRUE)
})

test_that("Typst-significant characters in a caption render literally in the List of Tables", {
  skip_quarto_tests()

  txt <- render_typst_pdf(c(
    "```{r echo=FALSE}",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(data.frame(x = 1)),",
    "  caption = 'Special: 50% * x_y # z',",
    "  label = 'special'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_match(txt, "Special: 50% * x_y # z", fixed = TRUE)
})

test_that("a typst-backend topic listing spans multiple pages with the header and topic repeating on each", {
  skip_quarto_tests()

  pages <- render_typst_pdf_pages(c(
    "```{=typst}",
    "#set page(height: 6cm)",
    "```",
    "",
    "```{r echo=FALSE}",
    "options(tabtibble.backend = 'typst')",
    "d <- data.frame(time = 0:19, value = round((0:19) * 1.1, 1))",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(d),",
    "  caption = 'A topic-grouped listing',",
    "  label = 'topiclisting',",
    "  topic_cols = list('time')", # each row its own group: guarantees > 1 group repeats across pages
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_gte(length(pages), 3)
  # the column header ("value") and *some* topic-row text repeat on every
  # page the table continues onto -- check the last three pages, which are
  # guaranteed to be pure table continuation (no title/List of Tables noise).
  n <- length(pages)
  for (p in pages[(n - 2):n]) {
    expect_match(p, "value", fixed = TRUE)
  }
})

test_that("a typst-backend table with a single topic group repeats that group's header on every continuation page", {
  skip_quarto_tests()

  pages <- render_typst_pdf_pages(c(
    "```{=typst}",
    "#set page(height: 6cm)",
    "```",
    "",
    "```{r echo=FALSE}",
    "options(tabtibble.backend = 'typst')",
    "d <- data.frame(",
    "  subject = rep('S001', 20),",
    "  time = 0:19,",
    "  value = round((0:19) * 1.1, 1)",
    ")",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(d),",
    "  caption = 'A single-subject listing',",
    "  label = 'onesubject',",
    "  topic_cols = list('subject')",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_gte(length(pages), 3)
  n <- length(pages)
  for (p in pages[(n - 2):n]) {
    expect_match(p, "S001", fixed = TRUE)
    expect_match(p, "value", fixed = TRUE)
  }
})

test_that("a typst-backend table without topic_cols is an ordinary (non-grouped) repeating-header table", {
  skip_quarto_tests()

  txt <- render_typst_pdf(c(
    "```{r echo=FALSE}",
    "options(tabtibble.backend = 'typst')",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(data.frame(x = 1:2, y = c('a', 'b'))),",
    "  caption = 'An ordinary typst-backend table',",
    "  label = 'ordinarytypst'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_match(txt, "An ordinary typst-backend table", fixed = TRUE)
  expect_match(txt, "Table 1", fixed = TRUE)
})

test_that("multiple backends each produce a crossreferenceable, captioned table", {
  skip_quarto_tests()
  skip_if_not_installed("tinytable")

  txt <- render_typst_pdf(c(
    "```{r echo=FALSE}",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(data.frame(x = 1), data.frame(x = 2)),",
    "  caption = c('Markdown backend table', 'Tinytable backend table'),",
    "  label = c('md', 'tt')",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "options(tabtibble.backend = 'markdown')",
    "knit_print(d_tab$table[1], caption = d_tab$caption[1], label = d_tab$label[1])",
    "options(tabtibble.backend = 'tinytable')",
    "knit_print(d_tab$table[2], caption = d_tab$caption[2], label = d_tab$label[2])",
    "```"
  ))

  expect_match(txt, "Markdown backend table", fixed = TRUE)
  expect_match(txt, "Tinytable backend table", fixed = TRUE)
  expect_match(txt, "Table 1", fixed = TRUE)
  expect_match(txt, "Table 2", fixed = TRUE)
})
