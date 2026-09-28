# Run `code` with `tabtibble.backend` temporarily set, restoring the prior
# option afterwards even if `code` errors.
with_tabtibble_backend <- function(backend, code) {
  old <- options(tabtibble.backend = backend)
  on.exit(options(old), add = TRUE)
  force(code)
}
