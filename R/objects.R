#' Create a new `tab_tibble` object
#'
#' @param x The object to convert
#' @returns An object with the desired class
#' @export
new_tab_tibble <- function(x) {
  stopifnot(is.data.frame(x))
  stopifnot(all(c("table", "caption") %in% names(x)))
  if (!inherits(x$table, "tab_list")) {
    x$table <- new_tab_list(x$table)
  }
  class(x) <- unique(c("tab_tibble", class(x)))
  x
}

#' @describeIn new_tab_tibble Create a new `tab_list` object
#' @export
new_tab_list <- function(x) {
  if (!inherits(x, "list")) {
    stop("`x` must be a list")
  }
  x_null <- vapply(X = x, FUN = is.null, FUN.VALUE = TRUE)
  x_df <- vapply(X = x, FUN = inherits, "data.frame", FUN.VALUE = TRUE)
  if (!all(x_null | x_df)) {
    stop("The contents of 'x' must be NULL or a 'data.frame'-like object")
  }
  vctrs::new_vctr(x, class = "tab_list")
}

vec_ptype_abbr.tab_list <- function(x, ...) {
  "tablist"
}

#' @export
format.tab_list <- function(x, ...) {
  sprintf("A %s object", vapply(X = x, FUN = \(x) class(x)[1], FUN.VALUE = ""))
}

#' @export
print.tab_list <- function(x, ...) {
  for (idx in seq_along(x)) {
    print(x[[idx]], ...)
  }
  invisible(x)
}
