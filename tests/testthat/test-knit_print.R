test_that("knit_print.tab_tibble (and implicitly knit_print.tab_list and print_tabtibble.tab_pander)", {
  d_tab_prep <- tidyr::nest(mtcars, table = !"cyl")
  d_tab_prep <- dplyr::mutate(d_tab_prep, caption = glue::glue("Cars with {cyl} cylinders"))
  d_tab <- new_tab_tibble(d_tab_prep)
  expect_output(
    suppressWarnings(knit_print(d_tab)),
    regexp = "Cars with 8 cylinders"
  )
  expect_output(
    suppressWarnings(knit_print(d_tab, tab_prefix = "foo")),
    regexp = "foo"
  )
})
