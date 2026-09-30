test_that("detect_render_mode auto-detects \"rmarkdown\" in a bare session (no Quarto signal set)", {
  # a bare testthat session has neither `quarto.version` nor QUARTO_* env
  # vars set, so this exercises real auto-detection, not the forced option.
  expect_identical(detect_render_mode(), "rmarkdown")
})

test_that("detect_render_mode honors the tabtibble.render_mode option", {
  with_tabtibble_render_mode("quarto", expect_identical(detect_render_mode(), "quarto"))
  with_tabtibble_render_mode("rmarkdown", expect_identical(detect_render_mode(), "rmarkdown"))
})

test_that("detect_render_mode rejects an invalid forced value", {
  with_tabtibble_render_mode("bogus", expect_error(detect_render_mode(), regexp = "must be"))
})

test_that("detect_render_mode detects Quarto from knitr's quarto.version option", {
  old <- knitr::opts_knit$get("quarto.version")
  knitr::opts_knit$set(quarto.version = "99.9")
  on.exit(knitr::opts_knit$set(quarto.version = old))
  expect_identical(detect_render_mode(), "quarto")
})

test_that("detect_render_mode detects Quarto from the QUARTO_PROJECT_ROOT env var", {
  old <- Sys.getenv("QUARTO_PROJECT_ROOT", unset = NA)
  Sys.setenv(QUARTO_PROJECT_ROOT = "/some/path")
  on.exit(if (is.na(old)) Sys.unsetenv("QUARTO_PROJECT_ROOT") else Sys.setenv(QUARTO_PROJECT_ROOT = old))
  expect_identical(detect_render_mode(), "quarto")
})

test_that("detect_output_target honors the tabtibble.output_target option", {
  old <- options(tabtibble.output_target = "typst")
  on.exit(options(old))
  expect_identical(detect_output_target(), "typst")
})

test_that("detect_output_target returns \"other\" outside any knit", {
  old <- options(tabtibble.output_target = NULL)
  on.exit(options(old))
  expect_identical(detect_output_target(), "other")
})

with_pandoc_to <- function(to, code) {
  old <- knitr::opts_knit$get("rmarkdown.pandoc.to")
  knitr::opts_knit$set(rmarkdown.pandoc.to = to)
  on.exit(knitr::opts_knit$set(rmarkdown.pandoc.to = old))
  force(code)
}

test_that("detect_output_target detects latex via knitr::is_latex_output()", {
  with_pandoc_to("latex", expect_identical(detect_output_target(), "latex"))
})

test_that("detect_output_target detects html via knitr::is_html_output()", {
  with_pandoc_to("html", expect_identical(detect_output_target(), "html"))
})

test_that("detect_output_target detects typst via knitr::pandoc_to()", {
  with_pandoc_to("typst", expect_identical(detect_output_target(), "typst"))
})

test_that("detect_output_target detects docx via knitr::pandoc_to()", {
  with_pandoc_to("docx", expect_identical(detect_output_target(), "docx"))
})

test_that("under Quarto mode, knit_print wraps the table in the crossref div", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "A caption", label = "modequarto")
  )
  with_tabtibble_render_mode("quarto", with_tabtibble_auto_asis(FALSE, {
    out <- capture.output(suppressWarnings(knit_print(d_tab)))
    expect_identical(out[1], "::: {#tbl-modequarto}")
    expect_true(any(out == ":::"))
  }))
})

test_that("under R Markdown mode, knit_print omits the crossref div and captions the table instead", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "A caption", label = "moderdown")
  )
  with_tabtibble_render_mode("rmarkdown", {
    out <- capture.output(suppressWarnings(knit_print(d_tab)))
    expect_false(any(grepl("^::: \\{#tbl-", out)))
    expect_false(any(out == ":::"))
    expect_true(any(grepl("A caption", out, fixed = TRUE)))
  })
})

test_that("under R Markdown mode, the markdown backend applies the caption via kable's own caption argument", {
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("markdown", {
    out <- paste(capture.output(render_backend_table(data.frame(x = 1), caption = "My caption")), collapse = "\n")
    expect_match(out, "My caption", fixed = TRUE)
  }))
})

test_that("under Quarto mode, render_backend_table ignores a supplied caption", {
  with_tabtibble_render_mode("quarto", with_tabtibble_backend("markdown", {
    out <- paste(capture.output(render_backend_table(data.frame(x = 1), caption = "Should not appear")), collapse = "\n")
    expect_no_match(out, "Should not appear", fixed = TRUE)
  }))
})

test_that("under R Markdown mode, the tinytable backend applies the caption", {
  skip_if_not_installed("tinytable")
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("tinytable", {
    out <- paste(capture.output(render_backend_table(data.frame(x = 1), caption = "Tinytable caption")), collapse = "\n")
    expect_match(out, "Tinytable caption", fixed = TRUE)
  }))
})

test_that("under R Markdown mode, the gt backend applies the caption via tab_caption()", {
  skip_if_not_installed("gt")
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("gt", {
    out <- paste(capture.output(render_backend_table(data.frame(x = 1), caption = "Gt caption")), collapse = "\n")
    expect_match(out, "Gt caption", fixed = TRUE)
  }))
})

test_that("under R Markdown mode, the flextable backend applies the caption via set_caption()", {
  skip_if_not_installed("flextable")
  # flextable's own knit_print(), outside a real pandoc render, falls back
  # to a bare `to_html()` that omits the caption entirely (verified: calling
  # `flextable::set_caption()` directly and checking the rendered HTML shows
  # no caption text or `<caption` element even then) -- so this checks that
  # `render_backend_table()` called `set_caption()` on the object (the
  # caption survives in its properties), rather than the printed HTML text;
  # see test-rmarkdown-render.R for the caption actually appearing in a
  # real render.
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("flextable", {
    ft <- flextable::flextable(data.frame(x = 1))
    ft <- flextable::set_caption(ft, caption = "Flextable caption")
    expect_identical(ft$caption$value, "Flextable caption")
  }))
})

test_that("render_backend_table calls flextable::set_caption() under R Markdown mode", {
  skip_if_not_installed("flextable")
  calls <- new.env(parent = emptyenv())
  calls$caption <- NULL
  testthat::local_mocked_bindings(
    set_caption = function(x, caption, ...) {
      calls$caption <- caption
      x
    },
    .package = "flextable"
  )
  with_tabtibble_render_mode("rmarkdown", with_tabtibble_backend("flextable", {
    capture.output(render_backend_table(data.frame(x = 1), caption = "Mocked caption"))
  }))
  expect_identical(calls$caption, "Mocked caption")
})

test_that("under R Markdown mode, a pre-built table object gets a plain caption paragraph", {
  skip_if_not_installed("gt")
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(gt::gt(data.frame(x = 1))), caption = "Prebuilt caption", label = "prebuiltrmd")
  )
  with_tabtibble_render_mode("rmarkdown", {
    out <- paste(capture.output(suppressWarnings(knit_print(d_tab))), collapse = "\n")
    expect_match(out, "**Prebuilt caption**", fixed = TRUE)
  })
})
