# Rendering backends for a plain data.frame table, selected by the
# `tabtibble.backend` option ("markdown" (default), "tinytable", "gt",
# "flextable", "typst"). Backends are only touched at print time -- `new_tab_tibble()`
# / `new_tab_list()` never load any of these packages -- so storing a plain
# data.frame in a `tab_list` carries no rendering dependency.
#
# A table element that is already a `gt`/`tinytable`/`flextable`/`table1`
# object (see `new_tab_list()`) is left exactly as the caller built it and
# printed via its own registered `knit_print()` method, regardless of
# `tabtibble.backend`.
#
# Under Quarto (`detect_render_mode()` == "quarto") the caption is applied
# once, by the crossref wrapper in `knit_print.tab_list()`, not by the
# backend's own caption argument here -- otherwise it would appear twice in
# the rendered Typst figure. Under plain R Markdown -- where that wrapper
# (a Pandoc fenced Div with no filter to interpret it) is skipped entirely,
# see `knit_print.tab_list()` -- the caption is instead applied via each
# backend's own captioning: `knitr::kable(caption =)`, `tinytable::tt(caption =)`,
# `gt::tab_caption()`, `flextable::set_caption()`. So older Rmd reports that
# never used Quarto keep a normal, visible caption.

#' Missing backend package condition
#'
#' @param pkg The name of the missing package.
#' @param backend The `tabtibble.backend` value that needed it.
#' @keywords internal
tabtibble_missing_package_error <- function(pkg, backend) {
  stop(
    structure(
      class = c("tabtibble_missing_package", "error", "condition"),
      list(
        message = sprintf(
          "The '%s' package is required for `tabtibble.backend = \"%s\"` but is not installed.",
          pkg, backend
        ),
        call = NULL,
        package = pkg,
        backend = backend
      )
    )
  )
}

require_backend_package <- function(pkg, backend) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    tabtibble_missing_package_error(pkg, backend)
  }
  invisible(TRUE)
}

# Re-emit another object's own `knit_print()` output as raw asis text.
# `knitr::knit_print()` returns a `knit_asis`-classed character vector; there
# is no `print.knit_asis` method, so the correct way to insert it into our
# own asis stream is to strip the class and `cat()` it (verified against a
# real Quarto -> Typst render; `print()`-ing the classed object instead just
# prints its literal string representation).
emit_knit_print <- function(x, ...) {
  cat(unclass(knitr::knit_print(x, ...)), sep = "\n")
  invisible(NULL)
}

#' Render a plain data.frame table body through the selected backend
#'
#' @param x A data.frame.
#' @param topic_cols Character vector of column names to group into
#'   repeating topic headers (see `render_typst_table()`); only used by the
#'   `"typst"` backend under Quarto. The other backends -- and `"typst"`
#'   itself outside Quarto, see below -- ignore it gracefully: the named
#'   columns stay as ordinary columns, so their values repeat on every row,
#'   as if `topic_cols` had not been set.
#' @param caption The table's caption, or `NULL`. Ignored under Quarto (the
#'   crossref wrapper in `knit_print.tab_list()` applies it instead); under
#'   R Markdown, applied via the backend's own captioning (see above).
#' @param ... Passed to the backend's table constructor
#'   (`knitr::kable()` / `tinytable::tt()` / `gt::gt()` /
#'   `flextable::flextable()`); unused by `"typst"`.
#' @returns `NULL`, invisibly; called for the side effect of writing the
#'   rendered table with `cat()`.
#' @keywords internal
render_backend_table <- function(x, topic_cols = character(0), caption = NULL, ...) {
  backend <- getOption("tabtibble.backend", "markdown")
  mode <- detect_render_mode()
  use_caption <- identical(mode, "rmarkdown") && !is.null(caption)
  caption <- if (use_caption) as.character(caption) else NULL

  # The "typst" backend's raw `{=typst}` blocks, and the crossref/List-of-
  # Tables machinery they rely on, are Quarto-specific; outside Quarto fall
  # back to the markdown backend so the table still renders (with its
  # caption, via the branch below) instead of dumping raw Typst source into
  # an R Markdown document.
  if (identical(backend, "typst") && !identical(mode, "quarto")) {
    backend <- "markdown"
  }

  switch(
    backend,
    markdown = {
      # "pipe" under Quarto, where every target (typst, html, pdf, ...)
      # goes through the same Pandoc-markdown intermediate; under R
      # Markdown, kable's own target-appropriate format (LaTeX/HTML/...)
      # instead, so the caption is a real table caption, not markdown text.
      format <- if (identical(mode, "quarto")) "pipe" else NULL
      cat(knitr::kable(escape_typst_df(x), format = format, caption = caption, ...), sep = "\n")
    },
    tinytable = {
      require_backend_package("tinytable", backend)
      emit_knit_print(tinytable::tt(escape_typst_df(x), caption = caption, ...))
    },
    gt = {
      require_backend_package("gt", backend)
      gt_obj <- gt::gt(x, ...)
      if (use_caption) {
        gt_obj <- gt::tab_caption(gt_obj, caption = caption)
      }
      emit_knit_print(gt_obj)
    },
    flextable = {
      require_backend_package("flextable", backend)
      ft_obj <- flextable::flextable(x, ...)
      if (use_caption) {
        ft_obj <- flextable::set_caption(ft_obj, caption = caption)
      }
      emit_knit_print(ft_obj)
    },
    typst = {
      render_typst_table(x, topic_cols = topic_cols)
    },
    stop(
      sprintf(
        "Unknown `tabtibble.backend` %s; must be one of \"markdown\", \"tinytable\", \"gt\", \"flextable\", \"typst\".",
        sQuote(backend, q = FALSE)
      ),
      call. = FALSE
    )
  )
  invisible(NULL)
}
