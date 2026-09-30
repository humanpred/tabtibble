test_that("new_tab_tibble", {
  new_tt <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo"))
  expect_s3_class(new_tt, "tab_tibble")
  expect_s3_class(new_tt$table, "tab_list")
  expect_type(new_tt$caption, "character")
})

test_that("new_tab_tibble derives a stable label when absent", {
  new_tt <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo"))
  expect_identical(new_tt$label, derive_label("foo"))

  # re-running on the same caption gives the same label (no randomness)
  new_tt2 <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo"))
  expect_identical(new_tt$label, new_tt2$label)
})

test_that("new_tab_tibble keeps a valid, explicit label", {
  new_tt <- new_tab_tibble(
    tibble::tibble(table = list(data.frame(a = 1)), caption = "foo", label = "my-table")
  )
  expect_identical(new_tt$label, "my-table")
})

test_that("new_tab_tibble derives a label only for rows with a missing/empty label", {
  new_tt <- new_tab_tibble(
    tibble::tibble(
      table   = list(data.frame(a = 1), data.frame(a = 2), data.frame(a = 3)),
      caption = c("one", "two", "three"),
      label   = c("explicit", NA_character_, "")
    )
  )
  expect_identical(new_tt$label, c("explicit", derive_label("two"), derive_label("three")))
})

test_that("new_tab_tibble rejects an invalid explicit label", {
  expect_error(
    new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo", label = "tbl-foo")),
    regexp = "must not include the 'tbl-' prefix"
  )
})

test_that("new_tab_tibble rejects duplicate labels", {
  expect_error(
    new_tab_tibble(
      tibble::tibble(
        table   = list(data.frame(a = 1), data.frame(a = 2)),
        caption = c("one", "two"),
        label   = c("dup", "dup")
      )
    ),
    regexp = "`label` values must be unique"
  )
})

test_that("new_tab_tibble accepts gt/tinytable/flextable objects in the table column", {
  skip_if_not_installed("gt")
  d <- data.frame(a = 1)
  new_tt <- new_tab_tibble(tibble::tibble(table = list(gt::gt(d)), caption = "a gt table"))
  expect_s3_class(new_tt, "tab_tibble")
  expect_s3_class(new_tt$table[[1]], "gt_tbl")
})

test_that("new_tab_list", {
  new_tl <- new_tab_list(list(data.frame(a = 1)))
  expect_s3_class(new_tl, "tab_list")

  expect_error(
    new_tab_list("A"),
    regexp = "`x` must be a list"
  )
  expect_error(
    new_tab_list(list("A")),
    regexp = "The contents of 'x' must be NULL, a 'data.frame'-like object, or a"
  )
})

test_that("new_tab_list accepts table1 objects", {
  skip_if_not_installed("table1")
  d  <- data.frame(x = c(1, 2, 3), g = c("a", "a", "b"))
  t1 <- table1::table1(~ x | g, data = d)
  expect_s3_class(t1, "table1")

  new_tl <- new_tab_list(list(t1))
  expect_s3_class(new_tl, "tab_list")

  new_tt <- new_tab_tibble(tibble::tibble(table = list(t1), caption = "Test table1"))
  expect_s3_class(new_tt, "tab_tibble")
  expect_s3_class(new_tt$table, "tab_list")
})

test_that("vctrs methods", {
  d_tab_prep <- tidyr::nest(mtcars, table = !"cyl")
  d_tab_prep <- dplyr::mutate(d_tab_prep, caption = glue::glue("Cars with {cyl} cylinders"))
  d_tab <- new_tab_tibble(d_tab_prep)
  expect_output(
    print(d_tab),
    regexp = "Cars with 8 cylinders"
  )
  expect_output(
    print(d_tab$table),
    "mpg"
  )
  expect_equal(vctrs::vec_ptype_abbr(d_tab$table), "tab_list")
})
