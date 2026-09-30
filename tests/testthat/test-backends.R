test_that("knit_print emits the exact expected markdown for a fixture table under Quarto", {
  d_tab <- new_tab_tibble(
    tibble::tibble(
      table   = list(data.frame(x = 1:2, y = c("a", "b"))),
      caption = "Fixture caption",
      label   = "fixture"
    )
  )
  out <- with_tabtibble_render_mode("quarto", capture.output(suppressWarnings(knit_print(d_tab))))
  expect_identical(
    out,
    c(
      "::: {#tbl-fixture}",
      "",
      "|  x|y  |",
      "|--:|:--|",
      "|  1|a  |",
      "|  2|b  |",
      "",
      "Fixture caption",
      "",
      ":::",
      "",
      ""
    )
  )
})

test_that("the markdown backend is the default", {
  expect_identical(getOption("tabtibble.backend", "markdown"), "markdown")
})

test_that("render_backend_table dispatches to knitr::kable for the markdown backend", {
  d <- data.frame(x = 1)
  out <- capture.output(render_backend_table(d))
  expect_identical(out, as.character(knitr::kable(d, format = "pipe")))
})

test_that("render_backend_table escapes Typst-significant characters for the markdown backend", {
  d <- data.frame(x = "a*b")
  out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
  expect_match(out, "a\\*b", fixed = TRUE)
})

test_that("render_backend_table dispatches to tinytable", {
  skip_if_not_installed("tinytable")
  with_tabtibble_backend("tinytable", {
    d <- data.frame(x = 1)
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    # tinytable's fallback (outside a real Quarto/knitr render) is a grid
    # table, distinct from the markdown backend's pipe-table syntax.
    expect_match(out, "+---+", fixed = TRUE)
    expect_no_match(out, "|--", fixed = TRUE)
  })
})

test_that("render_backend_table dispatches to gt without escaping cell text", {
  skip_if_not_installed("gt")
  with_tabtibble_backend("gt", {
    d <- data.frame(x = "a*b")
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    # gt's own HTML-to-Typst path already renders '*' literally; tabtibble
    # must not also escape it (that would double-escape).
    expect_match(out, "a*b", fixed = TRUE)
    expect_no_match(out, "a\\*b", fixed = TRUE)
  })
})

test_that("render_backend_table dispatches to flextable without escaping cell text", {
  skip_if_not_installed("flextable")
  with_tabtibble_backend("flextable", {
    d <- data.frame(x = "a*b")
    out <- paste(capture.output(render_backend_table(d)), collapse = "\n")
    expect_match(out, "a*b", fixed = TRUE)
    expect_no_match(out, "a\\*b", fixed = TRUE)
  })
})

test_that("render_backend_table errors on an unknown backend", {
  with_tabtibble_backend("nonexistent-backend", {
    expect_error(render_backend_table(data.frame(x = 1)), regexp = "Unknown `tabtibble.backend`")
  })
})

test_that("require_backend_package throws a classed error for a missing package", {
  cnd <- tryCatch(
    require_backend_package("this.package.does.not.exist", "tinytable"),
    error = function(e) e
  )
  expect_s3_class(cnd, "tabtibble_missing_package")
  expect_match(conditionMessage(cnd), "this.package.does.not.exist")
  expect_match(conditionMessage(cnd), "tinytable")
})

test_that("a pre-built gt/tinytable/flextable table is printed via its own knit_print, ignoring tabtibble.backend", {
  skip_if_not_installed("gt")
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(gt::gt(data.frame(x = 1))), caption = "A gt table", label = "prebuilt")
  )
  with_tabtibble_backend("markdown", {
    out <- paste(capture.output(suppressWarnings(knit_print(d_tab))), collapse = "\n")
    # gt's own knit_print output (e.g. its "gt_table" CSS class), not a
    # kable pipe table -- confirming tabtibble.backend = "markdown" was
    # ignored for a table the caller already built with gt.
    expect_match(out, "gt_table", fixed = TRUE)
    expect_no_match(out, "|--", fixed = TRUE)
  })
})
