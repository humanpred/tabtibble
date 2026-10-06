test_that("render_typst_table emits the exact expected Typst for a two-level topic fixture", {
  d <- data.frame(
    subject = c("S1", "S1", "S2"),
    analyte = c("X", "Y", "X"),
    time    = c(0, 0, 0),
    value   = c(1.5, 2.5, 3.5)
  )
  out <- capture.output(render_typst_table(d, topic_cols = c("subject", "analyte")))
  expect_identical(
    out,
    c(
      "```{=typst}",
      "#table(",
      "  columns: 2,",
      "  align: (right, right,),",
      "  table.header(repeat: true, [*time*], [*value*], table.hline(),),",
      "  table.header(level: 2, table.cell(colspan: 2)[*S1*]),",
      "  table.header(level: 3, table.cell(colspan: 2)[*X*]),",
      "  [0], [1.5],",
      "  table.header(level: 3, table.cell(colspan: 2)[*Y*]),",
      "  [0], [2.5],",
      "  table.header(level: 2, table.cell(colspan: 2)[*S2*]),",
      "  table.header(level: 3, table.cell(colspan: 2)[*X*]),",
      "  [0], [3.5],",
      "  table.hline(),",
      ")",
      "```"
    )
  )
})

test_that("render_typst_table emits an ordinary repeating-header table without topic_cols", {
  d <- data.frame(x = 1:2, y = c("a", "b"))
  out <- capture.output(render_typst_table(d))
  expect_identical(
    out,
    c(
      "```{=typst}",
      "#table(",
      "  columns: 2,",
      "  align: (right, left,),",
      "  table.header(repeat: true, [*x*], [*y*], table.hline(),),",
      "  [1], [a],",
      "  [2], [b],",
      "  table.hline(),",
      ")",
      "```"
    )
  )
  expect_no_match(paste(out, collapse = "\n"), "table.header(level:", fixed = TRUE)
})

test_that("render_typst_table escapes Typst-significant characters in cell and topic text", {
  d <- data.frame(subject = "S1*", value = "a_b")
  out <- paste(capture.output(render_typst_table(d, topic_cols = "subject")), collapse = "\n")
  # the topic header wraps the (already-escaped) value in bold markers: *<escaped>*
  expect_match(out, "[*S1\\**]", fixed = TRUE)
  expect_match(out, "[a\\_b]", fixed = TRUE)
})

test_that("render_typst_table right-aligns numeric columns and left-aligns others by default", {
  d <- data.frame(n = 1, s = "a")
  out <- capture.output(render_typst_table(d))
  expect_match(out[4], "align: \\(right, left,\\)")
})

test_that("render_typst_table honors an explicit named tabtibble_align attribute", {
  d <- data.frame(n = 1, s = "a")
  attr(d, "tabtibble_align") <- c(n = "center", s = "right")
  out <- capture.output(render_typst_table(d))
  expect_match(out[4], "align: \\(center, right,\\)")
})

test_that("render_typst_table errors on an invalid tabtibble_align value", {
  d <- data.frame(n = 1)
  attr(d, "tabtibble_align") <- c(n = "sideways")
  expect_error(render_typst_table(d), regexp = "must be")
})

test_that("resolve_typst_align errors when a named tabtibble_align is missing a column", {
  d <- data.frame(n = 1, s = "a")
  expect_error(
    resolve_typst_align(d, c(n = "left")),
    regexp = "missing an entry for column\\(s\\): 's'"
  )
})

test_that("resolve_typst_align errors when an unnamed tabtibble_align has the wrong length", {
  d <- data.frame(n = 1, s = "a")
  expect_error(
    resolve_typst_align(d, c("left")),
    regexp = "must be named, or the same length"
  )
})

test_that(".typst_header_cell(bold = FALSE) omits the bold markers", {
  expect_identical(.typst_header_cell("x", bold = FALSE), "[x]")
})

test_that("render_typst_table handles NA cells as empty", {
  d <- data.frame(x = c(1, NA))
  out <- paste(capture.output(render_typst_table(d)), collapse = "\n")
  expect_match(out, "[]", fixed = TRUE)
})

test_that("render_backend_table dispatches to the typst backend under Quarto", {
  d <- data.frame(x = 1)
  with_tabtibble_render_mode("quarto", with_tabtibble_backend("typst", {
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    expect_match(out, "{=typst}", fixed = TRUE)
    expect_match(out, "#table(", fixed = TRUE)
  }))
})

test_that("render_backend_table falls back to markdown for the typst backend outside Quarto", {
  d <- data.frame(x = 1)
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("typst", {
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    expect_no_match(out, "{=typst}", fixed = TRUE)
    expect_match(out, "|", fixed = TRUE)
  }))
})

test_that("markdown/tinytable/gt/flextable backends ignore topic_cols gracefully (values repeat)", {
  d <- data.frame(subject = c("S1", "S1"), value = 1:2)
  with_tabtibble_backend("markdown", {
    out <- paste(capture.output(render_backend_table(d, topic_cols = "subject")), collapse = "\n")
    expect_identical(lengths(regmatches(out, gregexpr("S1", out))), 2L)
  })
})

test_that("the other backends ignore the Typst-only attributes, and escape a raw column like any other", {
  d <- data.frame(Parameter = c("r.squared", "lambda.z"), Name = c("$r^2$", NA), Value = 1:2)
  attr(d, "tabtibble_header_cols") <- 1
  attr(d, "tabtibble_widths") <- c("auto", "1fr", "auto")
  attr(d, "tabtibble_topic_labels") <- TRUE
  attr(d, "tabtibble_typst_raw") <- "Name"
  with_tabtibble_render_mode("quarto", with_tabtibble_backend("markdown", {
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    expect_match(out, "\\$r^2\\$", fixed = TRUE)
    expect_no_match(out, "vline", fixed = TRUE)
  }))
  # The typst backend falls back to markdown outside Quarto, escaping the raw
  # column there too.
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("typst", {
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    expect_match(out, "\\$r^2\\$", fixed = TRUE)
  }))
  for (backend in c("tinytable", "gt", "flextable")) {
    skip_if_not_installed(backend)
    with_tabtibble_render_mode("quarto", with_tabtibble_backend(backend, {
      expect_no_error(utils::capture.output(render_backend_table(d)))
    }))
  }
})

test_that("emit_typst_breakable_figure_rule emits the expected raw block", {
  out <- capture.output(emit_typst_breakable_figure_rule())
  expect_identical(
    out,
    c(
      "```{=typst}",
      "#show figure.where(kind: \"quarto-float-tbl\"): set block(breakable: true)",
      "```",
      ""
    )
  )
})

test_that("knit_print emits the breakable-figure rule before the div, only for the typst backend under Quarto", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "x", label = "typ")
  )
  with_tabtibble_render_mode("quarto", with_tabtibble_auto_asis(FALSE, {
    with_tabtibble_backend("typst", {
      out <- capture.output(suppressWarnings(knit_print(d_tab)))
      expect_identical(out[1], "```{=typst}")
      expect_true(any(grepl("breakable: true", out, fixed = TRUE)))
      expect_true(which(grepl("breakable: true", out, fixed = TRUE)) < which(out == "::: {#tbl-typ}"))
    })
    with_tabtibble_backend("markdown", {
      out <- capture.output(suppressWarnings(knit_print(d_tab)))
      expect_false(any(grepl("breakable: true", out, fixed = TRUE)))
    })
  }))
})

test_that("render_typst_table frames the data with a rule under the header and one at the end, even with no rows", {
  out <- capture.output(render_typst_table(data.frame(x = numeric(0))))
  expect_identical(
    out,
    c(
      "```{=typst}",
      "#table(",
      "  columns: 1,",
      "  align: (right,),",
      "  table.header(repeat: true, [*x*], table.hline(),),",
      "  table.hline(),",
      ")",
      "```"
    )
  )
})

test_that("render_typst_table separates the row-header columns with a vertical rule", {
  d <- data.frame(Option = c("a", "b"), Value = 1:2, Default = 1:2)
  attr(d, "tabtibble_header_cols") <- 1
  out <- capture.output(render_typst_table(d))
  expect_identical(
    out[3:6],
    c(
      "  columns: 3,",
      "  align: (left, right, right,),",
      "  table.vline(x: 1),",
      "  table.header(repeat: true, [*Option*], [*Value*], [*Default*], table.hline(),),"
    )
  )
  # None, the default, writes no vertical rule.
  attr(d, "tabtibble_header_cols") <- 0
  expect_no_match(paste(capture.output(render_typst_table(d)), collapse = "\n"), "vline", fixed = TRUE)
})

test_that("render_typst_table refuses a tabtibble_header_cols that is not a count of leading data columns", {
  d <- data.frame(a = 1, b = 2)
  for (bad in list(2, -1, 1.5, NA_real_, c(1, 1), "1")) {
    attr(d, "tabtibble_header_cols") <- bad
    expect_error(render_typst_table(d), regexp = "`tabtibble_header_cols` must be a single whole number from 0 to 1")
  }
})

test_that("render_typst_table sets column widths from tabtibble_widths, named or in order", {
  d <- data.frame(Option = "a", Description = "b")
  attr(d, "tabtibble_widths") <- c(Description = "1fr", Option = "auto")
  expect_identical(capture.output(render_typst_table(d))[3], "  columns: (auto, 1fr,),")
  attr(d, "tabtibble_widths") <- c("3cm", "40%")
  expect_identical(capture.output(render_typst_table(d))[3], "  columns: (3cm, 40%,),")
  # Widths are for the data columns; a topic column takes none.
  d_topic <- data.frame(subject = "S1", Option = "a", Description = "b")
  attr(d_topic, "tabtibble_widths") <- c("auto", "2.5fr")
  expect_identical(capture.output(render_typst_table(d_topic, topic_cols = "subject"))[3], "  columns: (auto, 2.5fr,),")
})

test_that("resolve_typst_widths refuses widths that are missing, the wrong length, or not Typst track sizes", {
  d <- data.frame(a = 1, b = 2)
  expect_error(resolve_typst_widths(d, c(a = "auto")), regexp = "missing an entry for column\\(s\\): 'b'")
  expect_error(resolve_typst_widths(d, "auto"), regexp = "must be named, or the same length")
  expect_error(resolve_typst_widths(d, c("auto", "wide")), regexp = "must be Typst track sizes.*'wide'")
  expect_error(resolve_typst_widths(d, c("auto", NA)), regexp = "must be Typst track sizes.*NA")
  expect_error(resolve_typst_widths(d, c(1, 2)), regexp = "must be a character vector")
  expect_identical(resolve_typst_widths(d, NULL), "2")
})

test_that("resolve_typst_widths takes every name or none, each a data column once", {
  d <- data.frame(a = 1, b = 2)
  # A partly named vector is refused, not read by its names alone.
  expect_error(resolve_typst_widths(d, c(a = "1fr", "2fr")), regexp = "`tabtibble_widths` must name every width or none")
  # A name that is not a column is named in the error, even beside a
  # missing column.
  expect_error(
    resolve_typst_widths(d, c(a = "1fr", z = "2fr")),
    regexp = "`tabtibble_widths` names column\\(s\\) that are not data columns: 'z'"
  )
  expect_error(
    resolve_typst_widths(d, c(a = "1fr", b = "2fr", c = "auto")),
    regexp = "not data columns: 'c'"
  )
  expect_error(
    resolve_typst_widths(d, c(a = "1fr", a = "2fr", b = "auto")),
    regexp = "`tabtibble_widths` names column\\(s\\) more than once: 'a'"
  )
})

test_that("resolve_typst_widths accepts lengths and fractions with or without a leading zero", {
  d <- data.frame(a = 1, b = 2, c = 3, d = 4)
  expect_identical(resolve_typst_widths(d, c(".5cm", "0.5fr", "12.25pt", "auto")), "(.5cm, 0.5fr, 12.25pt, auto,)")
  expect_error(resolve_typst_widths(d, c("5.cm", "1fr", "1fr", "1fr")), regexp = "'5.cm'")
})

test_that("render_typst_table refuses a tabtibble_topic_labels that is not a single TRUE or FALSE", {
  d <- data.frame(subject = "S1", value = 1)
  for (bad in list("yes", 1, NA, c(TRUE, TRUE), logical(0))) {
    attr(d, "tabtibble_topic_labels") <- bad
    expect_error(
      render_typst_table(d, topic_cols = "subject"),
      regexp = "`tabtibble_topic_labels` must be a single TRUE or FALSE"
    )
  }
  attr(d, "tabtibble_topic_labels") <- FALSE
  expect_identical(
    capture.output(render_typst_table(d, topic_cols = "subject"))[6],
    "  table.header(level: 2, table.cell(colspan: 1)[*S1*]),"
  )
})

test_that("render_typst_table escapes column names in the column header and in topic headers", {
  d <- data.frame(`Sub_ject` = "S1", `AUC*` = 1, `Cmax#1` = 2, check.names = FALSE)
  attr(d, "tabtibble_topic_labels") <- TRUE
  out <- capture.output(render_typst_table(d, topic_cols = "Sub_ject"))
  expect_identical(out[5], "  table.header(repeat: true, [*AUC\\**], [*Cmax\\#1*], table.hline(),),")
  expect_identical(out[6], "  table.header(level: 2, table.cell(colspan: 2)[*Sub\\_ject: S1*]),")
})

test_that("resolve_typst_header_cols says so when every column is a topic column", {
  d <- data.frame(subject = "S1")
  attr(d, "tabtibble_header_cols") <- 1
  expect_error(
    render_typst_table(d, topic_cols = "subject"),
    regexp = "`tabtibble_header_cols` cannot be set on a table whose every column is a topic column"
  )
})

test_that("render_typst_table names each topic header's column with tabtibble_topic_labels", {
  d <- data.frame(Part = c("A", "A"), Subject = c("S001", "S_2"), value = 1:2)
  attr(d, "tabtibble_topic_labels") <- TRUE
  out <- capture.output(render_typst_table(d, topic_cols = c("Part", "Subject")))
  expect_identical(
    out[6:10],
    c(
      "  table.header(level: 2, table.cell(colspan: 1)[*Part: A*]),",
      "  table.header(level: 3, table.cell(colspan: 1)[*Subject: S001*]),",
      "  [1],",
      "  table.header(level: 3, table.cell(colspan: 1)[*Subject: S\\_2*]),",
      "  [2],"
    )
  )
  # Without the attribute, a topic header is the value alone.
  attr(d, "tabtibble_topic_labels") <- NULL
  out_plain <- capture.output(render_typst_table(d, topic_cols = c("Part", "Subject")))
  expect_identical(out_plain[6], "  table.header(level: 2, table.cell(colspan: 1)[*A*]),")
})

test_that("render_typst_table writes tabtibble_typst_raw columns as given and escapes the others", {
  d <- data.frame(Parameter = "r_sq", Name = "$r^2$")
  attr(d, "tabtibble_typst_raw") <- "Name"
  out <- capture.output(render_typst_table(d))
  expect_identical(out[6], "  [r\\_sq], [$r^2$],")
  attr(d, "tabtibble_typst_raw") <- NULL
  expect_identical(capture.output(render_typst_table(d))[6], "  [r\\_sq], [\\$r^2\\$],")
})

test_that("render_typst_table refuses tabtibble_typst_raw columns that are not data columns", {
  d <- data.frame(subject = "S1", Name = "$x$")
  attr(d, "tabtibble_typst_raw") <- c("Name", "subject")
  expect_error(render_typst_table(d, topic_cols = "subject"), regexp = "not data columns: 'subject'")
  attr(d, "tabtibble_typst_raw") <- "missing"
  expect_error(render_typst_table(d), regexp = "not data columns: 'missing'")
})
