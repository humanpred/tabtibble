test_that("new_tab_tibble", {
  new_tt <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo"))
  expect_s3_class(new_tt, "tab_tibble")
  expect_s3_class(new_tt$table, "tab_list")
  expect_type(new_tt$caption, "character")
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
    regexp = "The contents of 'x' must be NULL, a 'data.frame'-like object, or a 'table1' object"
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
