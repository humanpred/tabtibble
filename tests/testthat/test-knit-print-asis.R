# `tabtibble.knitr.auto.asis` (default TRUE): `knit_print()` returns a
# `knitr::asis_output()` value instead of `cat()`-ing directly, so a chunk
# needs no `results='asis'` -- one test per setting.

test_that("with auto.asis = TRUE (the default), knit_print returns a knit_asis value and writes nothing to the console", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "Auto caption", label = "autoasis")
  )
  with_tabtibble_render_mode("quarto", {
    out <- capture.output(result <- knit_print(d_tab))
    expect_identical(out, character(0))
    expect_s3_class(result, "knit_asis")
    expect_match(unclass(result), "::: {#tbl-autoasis}", fixed = TRUE)
    expect_match(unclass(result), "Auto caption", fixed = TRUE)
  })
})

test_that("with auto.asis = TRUE, no results='asis' warning is raised", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "x", label = "nowarn")
  )
  expect_no_warning(knit_print(d_tab))
})

test_that("with auto.asis = FALSE, knit_print writes to the console and warns without results='asis'", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "x", label = "warnasis")
  )
  with_tabtibble_auto_asis(FALSE, {
    expect_warning(capture.output(knit_print(d_tab)), regexp = "results='asis'")
    out <- capture.output(suppressWarnings(knit_print(d_tab)))
    expect_true(length(out) > 0)
  })
})

test_that("with auto.asis = FALSE, no warning is raised when results='asis' is already set", {
  old <- knitr::opts_current$get("results")
  knitr::opts_current$set(results = "asis")
  on.exit(knitr::opts_current$set(results = old))
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "x", label = "alreadyasis")
  )
  with_tabtibble_auto_asis(FALSE, {
    expect_no_warning(capture.output(knit_print(d_tab)))
  })
})

test_that("knit_print.tab_tibble propagates knit_print.tab_list's return value (both settings)", {
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(x = 1)), caption = "x", label = "propagate")
  )
  result_auto <- knit_print(d_tab)
  expect_s3_class(result_auto, "knit_asis")

  with_tabtibble_auto_asis(FALSE, {
    capture.output(result_manual <- suppressWarnings(knit_print(d_tab)))
    # in auto.asis = FALSE mode, the (invisible) return value is
    # knit_print.tab_list's own return (the tab_list, i.e. `d_tab$table`),
    # propagated through knit_print.tab_tibble rather than re-wrapped
    expect_identical(result_manual, d_tab$table)
  })
})

test_that("knit_print.tab_list derives labels itself when called directly without `label`", {
  tl <- new_tab_list(list(data.frame(a = 1)))
  with_tabtibble_render_mode("quarto", {
    result <- knit_print(tl, caption = "Direct caption")
    expect_match(unclass(result), paste0("tbl-", derive_label("Direct caption")), fixed = TRUE)
  })
})

test_that("knit_print.tab_list errors on duplicate labels passed directly", {
  tl <- new_tab_list(list(data.frame(a = 1), data.frame(a = 2)))
  expect_error(
    knit_print(tl, caption = c("a", "b"), label = c("dup", "dup")),
    regexp = "`label` values must be unique"
  )
})

test_that("print_tabtibble no longer requires a `caption` argument", {
  expect_no_error(capture.output(print_tabtibble(data.frame(x = 1))))
})
