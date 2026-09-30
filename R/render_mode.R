# Detecting whether a table is being printed under Quarto or under plain
# R Markdown/knitr, and (secondarily) the pandoc output target. Quarto's own
# crossref Div syntax (`::: {#tbl-<label>} ... :::`) is meaningless outside
# Quarto -- rendered by plain pandoc it shows up as a literal, uncaptioned
# wrapper -- so a table printed outside Quarto instead gets an ordinary
# captioned table the target understands (see `knit_print.tab_list()`).

#' Detect whether the current knit is running under Quarto or plain R Markdown
#'
#' `knitr::opts_knit$get("quarto.version")` is set whenever Quarto drives the
#' render (the same signal flextable's own `knit_print.flextable()` uses);
#' `QUARTO_PROJECT_ROOT` / `QUARTO_DOCUMENT_PATH` are set by the Quarto CLI
#' itself, including for a single-file (non-project) render, and are checked
#' as a fallback. Verified against a real Quarto 1.9.37 Typst render (all
#' three set) and a plain `rmarkdown::render()` (all three absent).
#'
#' @returns `"quarto"` or `"rmarkdown"`. The `tabtibble.render_mode` option
#'   forces the result (for tests, or when detection is wrong for some
#'   environment); it must be one of those two values.
#' @keywords internal
detect_render_mode <- function() {
  forced <- getOption("tabtibble.render_mode")
  if (!is.null(forced)) {
    if (!isTRUE(forced %in% c("quarto", "rmarkdown"))) {
      stop("`tabtibble.render_mode` must be \"quarto\" or \"rmarkdown\".", call. = FALSE)
    }
    return(forced)
  }
  is_quarto <- !is.null(knitr::opts_knit$get("quarto.version")) ||
    nzchar(Sys.getenv("QUARTO_PROJECT_ROOT", "")) ||
    nzchar(Sys.getenv("QUARTO_DOCUMENT_PATH", ""))
  if (is_quarto) "quarto" else "rmarkdown"
}

#' Detect the current knitr/pandoc output target
#'
#' @returns One of `"typst"`, `"latex"`, `"html"`, `"docx"`, or `"other"`
#'   (any other/undetected target, including not being inside a knit at
#'   all). The `tabtibble.output_target` option forces the result (for
#'   tests, or when detection is wrong for some environment).
#' @keywords internal
detect_output_target <- function() {
  forced <- getOption("tabtibble.output_target")
  if (!is.null(forced)) {
    return(forced)
  }
  if (isTRUE(knitr::is_latex_output())) {
    return("latex")
  }
  if (isTRUE(knitr::is_html_output())) {
    return("html")
  }
  to <- knitr::pandoc_to()
  if (!is.null(to) && grepl("typst", to, fixed = TRUE)) {
    return("typst")
  }
  if (!is.null(to) && grepl("docx", to, fixed = TRUE)) {
    return("docx")
  }
  "other"
}
