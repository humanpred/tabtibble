# Run `code` with `tabtibble.backend` temporarily set, restoring the prior
# option afterwards even if `code` errors.
with_tabtibble_backend <- function(backend, code) {
  old <- options(tabtibble.backend = backend)
  on.exit(options(old), add = TRUE)
  force(code)
}

# Run `code` with `tabtibble.render_mode` temporarily forced (`"quarto"` or
# `"rmarkdown"`), restoring the prior option afterwards even if `code`
# errors. A bare testthat session has neither `quarto.version` nor the
# `QUARTO_*` env vars set, so `detect_render_mode()` auto-detects
# "rmarkdown" there; tests that exercise Quarto-mode behavior force it
# explicitly instead of relying on that auto-detection.
with_tabtibble_render_mode <- function(mode, code) {
  old <- options(tabtibble.render_mode = mode)
  on.exit(options(old), add = TRUE)
  force(code)
}

# Run `code` with `tabtibble.knitr.auto.asis` temporarily set, restoring the
# prior option afterwards even if `code` errors. Most existing tests inspect
# `knit_print()`'s output via `capture.output()`, which only sees the old,
# `cat()`-based behavior (auto.asis = FALSE); they force that explicitly so
# they keep testing what they were written to test, independent of the
# auto-asis feature itself (see test-knit-print-asis.R for dedicated
# auto.asis tests).
with_tabtibble_auto_asis <- function(value, code) {
  old <- options(tabtibble.knitr.auto.asis = value)
  on.exit(options(old), add = TRUE)
  force(code)
}
