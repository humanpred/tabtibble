test_that("validate_label accepts a valid label", {
  expect_identical(validate_label("my-table_1"), "my-table_1")
})

test_that("validate_label rejects non-scalar/missing/empty input", {
  expect_error(validate_label(character(0)), regexp = "non-missing, non-empty character scalar")
  expect_error(validate_label(c("a", "b")), regexp = "non-missing, non-empty character scalar")
  expect_error(validate_label(NA_character_), regexp = "non-missing, non-empty character scalar")
  expect_error(validate_label(""), regexp = "non-missing, non-empty character scalar")
})

test_that("validate_label rejects the 'tbl-' prefix", {
  expect_error(validate_label("tbl-mytable"), regexp = "must not include the 'tbl-' prefix")
})

test_that("validate_label rejects characters outside [A-Za-z0-9_-]", {
  expect_error(validate_label("my table"), regexp = "letters, digits, '-', and '_'")
  expect_error(validate_label("my.table"), regexp = "letters, digits, '-', and '_'")
})

test_that("derive_label is stable (never random) for the same caption", {
  expect_identical(derive_label("Cars with 8 cylinders"), derive_label("Cars with 8 cylinders"))
})

test_that("derive_label produces a valid label", {
  expect_no_error(validate_label(derive_label("Cars with 8 cylinders")))
  expect_no_error(validate_label(derive_label("!!! only punctuation !!!")))
})

test_that("derive_label distinguishes captions that slugify to the same text", {
  # both slugify to "n" but differ in hashed content
  expect_false(identical(derive_label("N"), derive_label("n")))
})

test_that("derive_label falls back to the hash alone when the slug is empty", {
  label <- derive_label("!!! *** !!!")
  expect_no_error(validate_label(label))
  expect_match(label, "^[0-9a-f]{6}$")
})

# escape_typst(): one test per Typst/Pandoc-markdown-significant character,
# per the contract. Each is verified to render literally end-to-end in
# test-quarto-render.R; here we pin the exact escaped string.
test_that("escape_typst escapes '*'", {
  expect_identical(escape_typst("a*b"), "a\\*b")
})

test_that("escape_typst escapes '_'", {
  expect_identical(escape_typst("a_b"), "a\\_b")
})

test_that("escape_typst escapes '#'", {
  expect_identical(escape_typst("a#b"), "a\\#b")
})

test_that("escape_typst escapes '@'", {
  expect_identical(escape_typst("a@b"), "a\\@b")
})

test_that("escape_typst escapes '$'", {
  expect_identical(escape_typst("a$b"), "a\\$b")
})

test_that("escape_typst escapes '<'", {
  expect_identical(escape_typst("a<b"), "a\\<b")
})

test_that("escape_typst escapes '>'", {
  expect_identical(escape_typst("a>b"), "a\\>b")
})

test_that("escape_typst escapes backslash", {
  expect_identical(escape_typst("a\\b"), "a\\\\b")
})

test_that("escape_typst escapes backtick", {
  expect_identical(escape_typst("a`b"), "a\\`b")
})

test_that("escape_typst escapes '['", {
  expect_identical(escape_typst("a[b"), "a\\[b")
})

test_that("escape_typst escapes ']'", {
  expect_identical(escape_typst("a]b"), "a\\]b")
})

test_that("escape_typst escapes every special character in one string, in order", {
  raw <- "a*b_c#d@e$f<g>h\\i`j[k]l"
  expect_identical(
    escape_typst(raw),
    "a\\*b\\_c\\#d\\@e\\$f\\<g\\>h\\\\i\\`j\\[k\\]l"
  )
})

test_that("escape_typst leaves ordinary text untouched", {
  expect_identical(escape_typst("Cars with 8 cylinders"), "Cars with 8 cylinders")
})

test_that("escape_typst_df escapes character and factor columns only", {
  d <- data.frame(
    chr = "a*b",
    fct = factor("a_b"),
    num = 1.5,
    stringsAsFactors = FALSE
  )
  d_esc <- escape_typst_df(d)
  expect_identical(d_esc$chr, "a\\*b")
  expect_identical(as.character(d_esc$fct), "a\\_b")
  expect_identical(d_esc$num, 1.5)
})
