test_that("validate_topic_cols defaults to empty character vectors when NULL", {
  tables <- list(data.frame(a = 1), data.frame(a = 2))
  out <- validate_topic_cols(tables, NULL)
  expect_identical(out, list(character(0), character(0)))
})

test_that("validate_topic_cols treats a NULL element as empty", {
  tables <- list(data.frame(a = 1))
  out <- validate_topic_cols(tables, list(NULL))
  expect_identical(out, list(character(0)))
})

test_that("validate_topic_cols errors on length mismatch", {
  tables <- list(data.frame(a = 1), data.frame(a = 2))
  expect_error(validate_topic_cols(tables, list("a")), regexp = "same length")
})

test_that("validate_topic_cols errors on a non-character element", {
  tables <- list(data.frame(a = 1))
  expect_error(validate_topic_cols(tables, list(1)), regexp = "must be a character vector")
})

test_that("validate_topic_cols errors when a table is not a data.frame", {
  tables <- list("not a data.frame")
  expect_error(validate_topic_cols(tables, list("a")), regexp = "only supported for data.frame tables")
})

test_that("validate_topic_cols errors when a named column is missing", {
  tables <- list(data.frame(a = 1))
  expect_error(validate_topic_cols(tables, list("b")), regexp = "not present in the table.*'b'")
})

test_that("validate_topic_cols errors when the table is not sorted by topic_cols", {
  tables <- list(data.frame(subject = c("S2", "S1"), value = 1:2))
  expect_error(validate_topic_cols(tables, list("subject")), regexp = "not sorted by its `topic_cols`")
})

test_that("validate_topic_cols accepts a sorted table and passes topic_cols through", {
  tables <- list(data.frame(subject = c("S1", "S1", "S2"), value = 1:3))
  out <- validate_topic_cols(tables, list("subject"))
  expect_identical(out, list("subject"))
})

test_that("validate_topic_cols accepts an empty (0-row) table", {
  tables <- list(data.frame(subject = character(0), value = numeric(0)))
  out <- validate_topic_cols(tables, list("subject"))
  expect_identical(out, list("subject"))
})

test_that("topic_group_changes flags only row 1 with no topic_cols", {
  d <- data.frame(x = 1:3)
  out <- topic_group_changes(d, character(0))
  expect_identical(dim(out), c(3L, 0L))
})

test_that("topic_group_changes: single level, only flags actual changes", {
  d <- data.frame(subject = c("S1", "S1", "S1", "S2", "S2"))
  out <- topic_group_changes(d, "subject")
  expect_identical(out[, 1], c(TRUE, FALSE, FALSE, TRUE, FALSE))
})

test_that("topic_group_changes: an outer-level change forces the inner level to change too", {
  d <- data.frame(
    subject = c("S1", "S1", "S2", "S2"),
    analyte = c("X", "X", "X", "X") # same analyte throughout
  )
  out <- topic_group_changes(d, c("subject", "analyte"))
  expect_identical(out[, 1], c(TRUE, FALSE, TRUE, FALSE)) # subject
  expect_identical(out[, 2], c(TRUE, FALSE, TRUE, FALSE)) # analyte re-flagged when subject changes
})

test_that("topic_group_changes: an inner-level change alone doesn't flag the outer level", {
  d <- data.frame(
    subject = c("S1", "S1", "S1"),
    analyte = c("X", "Y", "Y")
  )
  out <- topic_group_changes(d, c("subject", "analyte"))
  expect_identical(out[, 1], c(TRUE, FALSE, FALSE)) # subject never changes after row 1
  expect_identical(out[, 2], c(TRUE, TRUE, FALSE))  # analyte changes at row 2
})

test_that("new_tab_tibble validates topic_cols and stores them", {
  d <- data.frame(subject = c("S1", "S1", "S2"), value = 1:3)
  d_tab <- new_tab_tibble(
    tibble::tibble(table = list(d), caption = "x", topic_cols = list("subject"))
  )
  expect_identical(d_tab$topic_cols, list("subject"))
})

test_that("new_tab_tibble defaults topic_cols to empty when absent", {
  d_tab <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "x"))
  expect_identical(d_tab$topic_cols, list(character(0)))
})

test_that("new_tab_tibble surfaces an unsorted-table error", {
  d <- data.frame(subject = c("S2", "S1"), value = 1:2)
  expect_error(
    new_tab_tibble(tibble::tibble(table = list(d), caption = "x", topic_cols = list("subject"))),
    regexp = "not sorted by its `topic_cols`"
  )
})
