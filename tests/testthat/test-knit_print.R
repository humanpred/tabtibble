test_that("knit_print.tab_tibble (and implicitly knit_print.tab_list and print_tablist_pander)", {
  d_tab <-
    mtcars |>
    tidyr::nest(table = !"cyl") |>
    dplyr::mutate(
      caption = glue::glue("Cars with {cyl} cylinders")
    ) |>
    new_tab_tibble()
  expect_output(
    knit_print(d_tab),
    regexp = "Cars with 8 cylinders"
  )
})
