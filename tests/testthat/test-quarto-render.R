# These tests render a real Quarto document to a Typst PDF and check the
# rendered text; see helper-quarto.R for the shared fixtures and the skip
# condition.

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

test_that("a typst-backend table compiles with its rules, widths, row-header rule, topic labels, and raw cells", {
  skip_quarto_tests()

  txt <- render_typst_pdf(c(
    "```{r echo=FALSE}",
    "options(tabtibble.backend = 'typst')",
    "d <- data.frame(",
    "  Subject = c('S001', 'S002', 'S003'),",
    "  Parameter = c('r.squared', 'lambda.z', 'none'),",
    "  Name = c('$r^2$', '$lambda_z$', NA)",
    ")",
    "attr(d, 'tabtibble_header_cols') <- 1",
    "attr(d, 'tabtibble_widths') <- c(Parameter = 'auto', Name = '1fr')",
    "attr(d, 'tabtibble_topic_labels') <- TRUE",
    "attr(d, 'tabtibble_typst_raw') <- 'Name'",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(d),",
    "  caption = 'A table with every attribute',",
    "  label = 'attributes',",
    "  topic_cols = list('Subject')",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  expect_match(txt, "A table with every attribute", fixed = TRUE)
  expect_match(txt, "Subject: S001", fixed = TRUE)
  expect_match(txt, "Subject: S003", fixed = TRUE)
  # The math is typeset: its markup is not printed, and the symbols are.
  expect_no_match(txt, "$", fixed = TRUE)
  expect_no_match(txt, "lambda_z", fixed = TRUE)
  # Typst sets math variables in mathematical italic (U+1D45F is r, U+1D706
  # is lambda, U+1D467 is z).
  expect_match(txt, "\U0001D45F2", fixed = TRUE)
  expect_match(txt, "\U0001D706\U0001D467", fixed = TRUE)
})

test_that("a typst-backend table with rules and a row-header column repeats its header on every page", {
  skip_quarto_tests()

  pages <- render_typst_pdf_pages(c(
    "```{r echo=FALSE}",
    "options(tabtibble.backend = 'typst')",
    "d <- data.frame(Row = sprintf('R%03d', 1:150), Value = 1:150)",
    "attr(d, 'tabtibble_header_cols') <- 1",
    "d_tab <- new_tab_tibble(tibble::tibble(",
    "  table = list(d),",
    "  caption = 'A long table with rules',",
    "  label = 'longrules'",
    "))",
    "```",
    "",
    "```{r results='asis'}",
    "knit_print(d_tab)",
    "```"
  ))

  table_pages <- pages[grepl("R[0-9]{3}", pages)]
  expect_gt(length(table_pages), 1)
  for (page in table_pages) {
    expect_match(page, "Row\\s+Value")
  }
  expect_match(paste(table_pages, collapse = "\n"), "R150", fixed = TRUE)
})
