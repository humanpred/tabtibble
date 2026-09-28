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
# The caption is applied once, by the crossref wrapper in
# `knit_print.tab_list()`, not by the backend's own caption argument here --
# otherwise it would appear twice in the rendered Typst figure.

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
#'   `"typst"` backend. The other backends ignore it gracefully -- the named
#'   columns stay as ordinary columns, so their values repeat on every row,
#'   as if `topic_cols` had not been set.
#' @param ... Passed to the backend's table constructor
#'   (`knitr::kable()` / `tinytable::tt()` / `gt::gt()` /
#'   `flextable::flextable()`); unused by `"typst"`.
#' @returns `NULL`, invisibly; called for the side effect of writing the
#'   rendered table with `cat()`.
#' @keywords internal
render_backend_table <- function(x, topic_cols = character(0), ...) {
  backend <- getOption("tabtibble.backend", "markdown")
  switch(
    backend,
    markdown = {
      cat(knitr::kable(escape_typst_df(x), format = "pipe", ...), sep = "\n")
    },
    tinytable = {
      require_backend_package("tinytable", backend)
      emit_knit_print(tinytable::tt(escape_typst_df(x), ...))
    },
    gt = {
      require_backend_package("gt", backend)
      emit_knit_print(gt::gt(x, ...))
    },
    flextable = {
      require_backend_package("flextable", backend)
      emit_knit_print(flextable::flextable(x, ...))
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
