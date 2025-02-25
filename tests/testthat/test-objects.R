test_that("new_tab_tibble", {
  new_tt <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo"))
  expect_s3_class(new_tt, "tab_tibble")
  expect_s3_class(new_tt$table, "tab_list")
  expect_type(new_tt$caption, "character")
})

test_that("new_tab_list", {
  new_tl <- new_tab_list(list(data.frame(a = 1)))
  expect_s3_class(new_tl, "tab_list")
})
