# The "typst" backend: a hand-written raw Typst `#table(...)` (no new
# dependency -- Typst's `table.header(level = ...)` already gives repeating,
# nested group headers, verified against the installed Typst 0.14.2). This
# reproduces LaTeX's TopicLongTable: a `topic_cols` group value is printed
# once, above its rows, and repeats (with the column header) at the top of
# each page the group continues onto.

#' Resolve per-column Typst table alignment
#'
#' @param x A data.frame (the data columns only, i.e. with any `topic_cols`
#'   already removed).
#' @param align `NULL` to use the default (numeric columns right-aligned,
#'   everything else left), or the `"tabtibble_align"` attribute set by the
#'   caller: a character vector of `"left"`/`"right"`/`"center"`, either
#'   named by column or in column order.
#' @returns A character vector of Typst alignment keywords, one per column
#'   of `x`.
#' @keywords internal
resolve_typst_align <- function(x, align = NULL) {
  cols <- names(x)
  if (is.null(align)) {
    return(vapply(x, function(col) if (is.numeric(col)) "right" else "left", character(1)))
  }
  if (!is.null(names(align))) {
    missing_cols <- setdiff(cols, names(align))
    if (length(missing_cols) > 0) {
      stop(
        sprintf("`tabtibble_align` is missing an entry for column(s): %s", paste(sQuote(missing_cols), collapse = ", ")),
        call. = FALSE
      )
    }
    align <- align[cols]
  } else if (length(align) != length(cols)) {
    stop("`tabtibble_align` must be named, or the same length as the number of (non-topic) columns.", call. = FALSE)
  }
  if (!all(align %in% c("left", "right", "center"))) {
    stop("`tabtibble_align` values must be \"left\", \"right\", or \"center\".", call. = FALSE)
  }
  unname(align)
}

# One cell's display text, matching `escape_typst_df()`'s coverage: NA
# becomes empty (Typst renders an empty cell, as `knitr::kable()` does for
# NA by default), everything else via `format()` so numeric columns keep
# ordinary R formatting.
.format_typst_cell <- function(x) {
  out <- format(x, trim = TRUE, justify = "none")
  out[is.na(x)] <- ""
  out
}

# `#table(...)` column spec cells: `[label]`, `[label], colspan: n` is not
# how Typst positional table cells take extra arguments -- a colspan needs
# `table.cell(colspan: n)[label]`.
.typst_cell <- function(label) {
  sprintf("[%s]", label)
}

.typst_header_cell <- function(label, bold = TRUE) {
  if (bold) sprintf("[*%s*]", label) else sprintf("[%s]", label)
}

#' Render a data.frame as a raw Typst table, with optional repeating topic headers
#'
#' Emits a fenced `{=typst}` block (which Quarto passes through verbatim)
#' containing a `#table(...)` whose column header repeats
#' (`table.header(repeat: true, ...)`) on every page the table continues
#' onto. When `topic_cols` is non-empty, each distinct combination of topic
#' values is additionally emitted once, as its own repeating header row
#' (`table.header(level = 2, ...)` for the first topic column, `level = 3`
#' for the second, and so on) spanning the data columns, immediately above
#' its rows; `x` must already be sorted by `topic_cols` (`new_tab_tibble()`
#' checks this). A topic header is never left alone at the bottom of a page
#' -- Typst keeps a `table.header` row with at least the row after it,
#' verified against a render long enough to force the break. Without
#' `topic_cols`, this is an ordinary repeating-header table.
#'
#' @param x A data.frame.
#' @param topic_cols Character vector of column names (outer to inner) to
#'   group into repeating topic headers, or `character(0)` (the default)
#'   for an ordinary table.
#' @param ... Unused; present for interface consistency with the other
#'   backends.
#' @returns `NULL`, invisibly; called for the side effect of writing the
#'   rendered table with `cat()`.
#' @keywords internal
render_typst_table <- function(x, topic_cols = character(0), ...) {
  x <- escape_typst_df(x)
  data_cols <- setdiff(names(x), topic_cols)
  n_col <- length(data_cols)
  align <- resolve_typst_align(x[data_cols], attr(x, "tabtibble_align"))

  cat("```{=typst}\n")
  cat("#table(\n")
  cat("  columns: ", n_col, ",\n", sep = "")
  cat("  align: (", paste(align, collapse = ", "), ",),\n", sep = "")
  cat(
    "  table.header(repeat: true, ",
    paste(vapply(data_cols, .typst_header_cell, character(1)), collapse = ", "), ",),\n",
    sep = ""
  )

  n_row <- nrow(x)
  if (n_row > 0 && length(topic_cols) > 0) {
    changes <- topic_group_changes(x, topic_cols)
  }
  for (i in seq_len(n_row)) {
    if (length(topic_cols) > 0) {
      for (lvl in seq_along(topic_cols)) {
        if (changes[i, lvl]) {
          value <- .format_typst_cell(x[[topic_cols[[lvl]]]][i])
          cat(
            "  table.header(level: ", lvl + 1L,
            ", table.cell(colspan: ", n_col, ")[*", value, "*]),\n",
            sep = ""
          )
        }
      }
    }
    cells <- vapply(data_cols, function(cn) .typst_cell(.format_typst_cell(x[[cn]][i])), character(1))
    cat("  ", paste(cells, collapse = ", "), ",\n", sep = "")
  }
  cat(")\n```\n")
  invisible(NULL)
}

# Long raw-Typst tables must be allowed to break across pages: Typst's
# `figure` is non-breakable by default (verified against Typst 0.14.2 --
# without this, a table taller than one page overlaps itself rather than
# continuing onto the next page). This must be emitted as its own top-level
# `{=typst}` block *before* the table's `::: {#tbl-<label>}` div, not
# inside it: a `#show` rule placed inside the div ends up nested inside
# Quarto's own `#figure(...)` call for that div (its content becomes the
# figure's body argument), too late to affect whether that figure itself is
# breakable.
emit_typst_breakable_figure_rule <- function() {
  cat("```{=typst}\n#show figure.where(kind: \"quarto-float-tbl\"): set block(breakable: true)\n```\n\n")
  invisible(NULL)
}
