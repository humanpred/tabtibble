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

#' Resolve per-column Typst column widths
#'
#' @param x A data.frame (the data columns only).
#' @param widths `NULL` for Typst's automatic widths, or the
#'   `"tabtibble_widths"` attribute: Typst track sizes (`"auto"`, a length
#'   such as `"3cm"` or `"40%"`, or a fraction such as `"2fr"`), either named
#'   by column or in column order.
#' @returns The Typst `columns:` value: the number of columns when `widths`
#'   is `NULL`, otherwise a Typst array of track sizes.
#' @keywords internal
resolve_typst_widths <- function(x, widths = NULL) {
  cols <- names(x)
  if (is.null(widths)) {
    return(as.character(length(cols)))
  }
  if (!is.null(names(widths))) {
    missing_cols <- setdiff(cols, names(widths))
    if (length(missing_cols) > 0) {
      stop(
        sprintf("`tabtibble_widths` is missing an entry for column(s): %s", paste(sQuote(missing_cols), collapse = ", ")),
        call. = FALSE
      )
    }
    widths <- widths[cols]
  } else if (length(widths) != length(cols)) {
    stop("`tabtibble_widths` must be named, or the same length as the number of (non-topic) columns.", call. = FALSE)
  }
  valid <- grepl("^(auto|[0-9]+(\\.[0-9]+)?(pt|mm|cm|in|em|%|fr))$", widths)
  if (!all(valid)) {
    stop(
      sprintf(
        "`tabtibble_widths` values must be Typst track sizes (\"auto\", a length such as \"3cm\" or \"40%%\", or a fraction such as \"2fr\"): %s",
        paste(sQuote(widths[!valid]), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  sprintf("(%s,)", paste(unname(widths), collapse = ", "))
}

#' Resolve the number of leading row-header columns
#'
#' @param x A data.frame (the data columns only).
#' @param header_cols `NULL` (none), or the `"tabtibble_header_cols"`
#'   attribute: the number of leading data columns that label their rows.
#' @returns A single integer, `0` when there are none.
#' @keywords internal
resolve_typst_header_cols <- function(x, header_cols = NULL) {
  if (is.null(header_cols)) {
    return(0L)
  }
  ok <- is.numeric(header_cols) && length(header_cols) == 1 && !is.na(header_cols) &&
    header_cols == round(header_cols) && header_cols >= 0 && header_cols < ncol(x)
  if (!ok) {
    stop(
      sprintf(
        "`tabtibble_header_cols` must be a single whole number from 0 to %d (one less than the number of (non-topic) columns).",
        ncol(x) - 1L
      ),
      call. = FALSE
    )
  }
  as.integer(header_cols)
}

#' Render a data.frame as a raw Typst table, with optional repeating topic headers
#'
#' Emits a fenced `{=typst}` block (which Quarto passes through verbatim)
#' containing a `#table(...)` whose column header repeats
#' (`table.header(repeat: true, ...)`) on every page the table continues
#' onto. A rule (`table.hline()`) closes the column header, so it repeats
#' with it under the header on every page, and another ends the table: the
#' rules frame the data. When `topic_cols` is non-empty, each distinct
#' combination of topic values is additionally emitted once, as its own
#' repeating header row (`table.header(level = 2, ...)` for the first topic
#' column, `level = 3` for the second, and so on) spanning the data columns,
#' immediately above its rows; `x` must already be sorted by `topic_cols`
#' (`new_tab_tibble()` checks this). A topic header is never left alone at
#' the bottom of a page -- Typst keeps a `table.header` row with at least the
#' row after it, verified against a render long enough to force the break.
#' Without `topic_cols`, this is an ordinary repeating-header table.
#'
#' Attributes of `x` adjust the table:
#'
#' * `"tabtibble_align"`: the column alignment; see `resolve_typst_align()`.
#' * `"tabtibble_widths"`: the column widths; see `resolve_typst_widths()`.
#' * `"tabtibble_header_cols"`: the number of leading data columns that
#'   label their rows; a vertical rule (`table.vline()`) separates them from
#'   the other columns.
#' * `"tabtibble_topic_labels"`: `TRUE` to show each topic header as
#'   "<column name>: <value>" instead of the value alone, so a topic row says
#'   what it is.
#' * `"tabtibble_typst_raw"`: the names of data columns whose cells are
#'   already Typst markup (for example `$r^2$`); they are written as given,
#'   not escaped, so the caller escapes any literal text in them.
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
  raw_cols <- attr(x, "tabtibble_typst_raw", exact = TRUE)
  if (is.null(raw_cols)) {
    raw_cols <- character(0)
  }
  topic_labels <- isTRUE(attr(x, "tabtibble_topic_labels", exact = TRUE))
  data_cols <- setdiff(names(x), topic_cols)
  bad_raw <- setdiff(raw_cols, data_cols)
  if (length(bad_raw) > 0) {
    stop(
      sprintf("`tabtibble_typst_raw` names column(s) that are not data columns: %s", paste(sQuote(bad_raw), collapse = ", ")),
      call. = FALSE
    )
  }
  x_raw <- x[raw_cols]
  x <- escape_typst_df(x)
  x[raw_cols] <- x_raw
  n_col <- length(data_cols)
  align <- resolve_typst_align(x[data_cols], attr(x, "tabtibble_align", exact = TRUE))
  columns <- resolve_typst_widths(x[data_cols], attr(x, "tabtibble_widths", exact = TRUE))
  header_cols <- resolve_typst_header_cols(x[data_cols], attr(x, "tabtibble_header_cols", exact = TRUE))
  topic_names <- escape_typst(topic_cols)

  cat("```{=typst}\n")
  cat("#table(\n")
  cat("  columns: ", columns, ",\n", sep = "")
  cat("  align: (", paste(align, collapse = ", "), ",),\n", sep = "")
  if (header_cols > 0) {
    cat("  table.vline(x: ", header_cols, "),\n", sep = "")
  }
  cat(
    "  table.header(repeat: true, ",
    paste(vapply(data_cols, .typst_header_cell, character(1)), collapse = ", "), ", table.hline(),),\n",
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
          if (topic_labels) {
            value <- paste0(topic_names[[lvl]], ": ", value)
          }
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
  cat("  table.hline(),\n")
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
