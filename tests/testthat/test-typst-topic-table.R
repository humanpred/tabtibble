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
      "  table.header(repeat: true, [*time*], [*value*],),",
      "  table.header(level: 2, table.cell(colspan: 2)[*S1*]),",
      "  table.header(level: 3, table.cell(colspan: 2)[*X*]),",
      "  [0], [1.5],",
      "  table.header(level: 3, table.cell(colspan: 2)[*Y*]),",
      "  [0], [2.5],",
      "  table.header(level: 2, table.cell(colspan: 2)[*S2*]),",
      "  table.header(level: 3, table.cell(colspan: 2)[*X*]),",
      "  [0], [3.5],",
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
      "  table.header(repeat: true, [*x*], [*y*],),",
      "  [1], [a],",
      "  [2], [b],",
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
  with_tabtibble_render_mode("quarto", {
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
  })
})
