#' Create a new `tab_tibble` object
#'
#' @param x The object to convert. A data.frame (or tibble) with columns
#'   `table` (list of tables; see `new_tab_list()`), `caption` (character),
#'   and optionally `label` (character, unique, a valid Quarto label without
#'   the `tbl-` prefix -- see `derive_label()`). When `label` is absent or
#'   `NA`/empty for a row, a stable label is derived from that row's caption,
#'   so re-rendering the same caption always yields the same label.
#' @returns An object with the desired class
#' @export
new_tab_tibble <- function(x) {
  stopifnot(is.data.frame(x))
  stopifnot(all(c("table", "caption") %in% names(x)))
  if (!inherits(x$table, "tab_list")) {
    x$table <- new_tab_list(x$table)
  }
  x$caption <- as.character(x$caption)
  if (!("label" %in% names(x))) {
    x$label <- rep(NA_character_, nrow(x))
  }
  x$label <- as.character(x$label)
  missing_label <- is.na(x$label) | !nzchar(x$label)
  for (idx in which(!missing_label)) {
    validate_label(x$label[[idx]])
  }
  if (any(missing_label)) {
    x$label[missing_label] <- vapply(x$caption[missing_label], derive_label, character(1))
  }
  if (anyDuplicated(x$label)) {
    dupes <- unique(x$label[duplicated(x$label)])
    stop(
      sprintf("`label` values must be unique; duplicated: %s", paste(sQuote(dupes), collapse = ", ")),
      call. = FALSE
    )
  }
  class(x) <- unique(c("tab_tibble", class(x)))
  x
}

# Classes accepted in a `tab_list` beyond plain data.frame-like objects:
# pre-built tables from each rendering backend (gt_tbl, tinytable,
# flextable), which are checked by class name only -- `inherits()` never
# loads the package, so this validation does not require gt/tinytable/
# flextable to be installed unless the caller actually passes one.
.tab_list_prebuilt_classes <- c("gt_tbl", "tinytable", "flextable", "table1")

#' @describeIn new_tab_tibble Create a new `tab_list` object
#' @export
new_tab_list <- function(x) {
  if (!inherits(x, "list")) {
    stop("`x` must be a list")
  }
  x_null     <- vapply(X = x, FUN = is.null,  FUN.VALUE = TRUE)
  x_df       <- vapply(X = x, FUN = inherits, "data.frame", FUN.VALUE = TRUE)
  x_prebuilt <- vapply(X = x, FUN = inherits, .tab_list_prebuilt_classes, FUN.VALUE = TRUE)
  if (!all(x_null | x_df | x_prebuilt)) {
    stop(
      "The contents of 'x' must be NULL, a 'data.frame'-like object, or a ",
      "'gt', 'tinytable', 'flextable', or 'table1' object"
    )
  }
  vctrs::new_vctr(x, class = "tab_list")
}

#' @exportS3Method vctrs::vec_ptype_abbr
vec_ptype_abbr.tab_list <- function(x, ...) {
  "tab_list"
}

#' @export
format.tab_list <- function(x, ...) {
  sprintf("A %s object", vapply(X = x, FUN = function(x) class(x)[1], FUN.VALUE = ""))
}

#' @export
print.tab_list <- function(x, ...) {
  for (idx in seq_along(x)) {
    print(x[[idx]], ...)
  }
  invisible(x)
}
