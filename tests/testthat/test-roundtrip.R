test_that("a tab_tibble survives saveRDS()/readRDS() with byte-identical knit_print output", {
  d_tab <- new_tab_tibble(
    tibble::tibble(
      table   = list(data.frame(x = 1:2, y = c("a", "b"))),
      caption = "Round-trip caption",
      label   = "roundtrip"
    )
  )
  before <- capture.output(suppressWarnings(knit_print(d_tab)))

  tmp <- tempfile(fileext = ".rds")
  on.exit(unlink(tmp))
  saveRDS(d_tab, tmp)
  d_tab_rt <- readRDS(tmp)

  expect_identical(d_tab, d_tab_rt)

  after <- capture.output(suppressWarnings(knit_print(d_tab_rt)))
  expect_identical(before, after)
})

test_that("a tab_tibble with derived labels survives saveRDS()/readRDS() identically (targets-style storage)", {
  d_tab <- new_tab_tibble(
    tibble::tibble(
      table   = list(data.frame(x = 1), data.frame(x = 2)),
      caption = c("First table", "Second table")
    )
  )
  tmp <- tempfile(fileext = ".rds")
  on.exit(unlink(tmp))
  saveRDS(d_tab, tmp)
  d_tab_rt <- readRDS(tmp)

  expect_identical(d_tab$label, d_tab_rt$label)
  expect_identical(
    capture.output(suppressWarnings(knit_print(d_tab))),
    capture.output(suppressWarnings(knit_print(d_tab_rt)))
  )
})
