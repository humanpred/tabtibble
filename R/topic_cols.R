# Validation for the optional `topic_cols` tab_tibble column: a list column,
# one character vector per table, naming the columns (in outer-to-inner
# order) that the "typst" backend groups into repeating topic headers
# instead of repeating their values on every row (see `render_typst_table()`
# and the TopicLongTable-style listing this reproduces).

#' Validate and normalize a `topic_cols` list column against its tables
#'
#' @param tables A `tab_list` (or plain list of tables).
#' @param topic_cols A list the same length as `tables`, or `NULL` (treated
#'   as all-empty).
#' @returns A list the same length as `tables`, each element a (possibly
#'   empty) character vector, validated against its table.
#' @keywords internal
validate_topic_cols <- function(tables, topic_cols) {
  n <- length(tables)
  if (is.null(topic_cols)) {
    return(replicate(n, character(0), simplify = FALSE))
  }
  if (length(topic_cols) != n) {
    stop("`topic_cols` must be the same length as the number of tables.", call. = FALSE)
  }
  for (idx in seq_len(n)) {
    tc <- topic_cols[[idx]]
    if (is.null(tc)) {
      tc <- character(0)
    }
    if (!is.character(tc)) {
      stop(sprintf("`topic_cols[[%d]]` must be a character vector (or NULL).", idx), call. = FALSE)
    }
    if (length(tc) > 0) {
      tbl <- tables[[idx]]
      if (!is.data.frame(tbl)) {
        stop(
          sprintf("`topic_cols` is only supported for data.frame tables; row %d is not a data.frame.", idx),
          call. = FALSE
        )
      }
      missing_cols <- setdiff(tc, names(tbl))
      if (length(missing_cols) > 0) {
        stop(
          sprintf(
            "`topic_cols[[%d]]` names columns not present in the table: %s",
            idx, paste(sQuote(missing_cols), collapse = ", ")
          ),
          call. = FALSE
        )
      }
      if (nrow(tbl) > 0) {
        ord <- do.call(order, unname(as.list(tbl[tc])))
        if (!identical(ord, seq_len(nrow(tbl)))) {
          stop(
            sprintf(
              "The table at row %d is not sorted by its `topic_cols` (%s); sort the data before calling `new_tab_tibble()`.",
              idx, paste(tc, collapse = ", ")
            ),
            call. = FALSE
          )
        }
      }
    }
    topic_cols[[idx]] <- tc
  }
  topic_cols
}

# Which rows need a new topic-group header emitted, at each topic level.
# Standard "control break" report logic: a level's header is (re-)emitted at
# a row when its own value differs from the previous row, or when any
# higher (outer) level's header was (re-)emitted at that row -- entering a
# new outer group always starts a new inner group too, even if the inner
# value happens to repeat.
#
# @param x A data.frame.
# @param topic_cols Character vector of column names, outer to inner.
# @returns A logical matrix, `nrow(x)` by `length(topic_cols)`.
# @keywords internal
topic_group_changes <- function(x, topic_cols) {
  n <- nrow(x)
  changed <- matrix(FALSE, nrow = n, ncol = length(topic_cols))
  above <- rep(FALSE, n) # no outer level above the first; its own row-1 TRUE (below) starts the cascade
  for (lvl in seq_along(topic_cols)) {
    val <- as.character(x[[topic_cols[[lvl]]]])
    own <- if (n > 1) c(TRUE, val[-1] != val[-n]) else rep(TRUE, n) # row 1 always starts a group
    this_level <- own | above
    changed[, lvl] <- this_level
    above <- this_level
  }
  changed
}
