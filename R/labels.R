# Quarto table labels: validation of user-supplied labels, and a stable
# fallback derivation (slug + short hash) for tables that don't supply one.
#
# The hash uses a base R (dependency-free) rolling hash rather than `digest`,
# since label derivation is on the core, always-invoked path of
# `new_tab_tibble()` and does not need cryptographic strength -- only
# stability across sessions and a low collision rate for the small number of
# captions a report table list typically holds.

.valid_label_regex <- "^[A-Za-z0-9_-]+$"

#' Validate a user-supplied Quarto table label
#'
#' @param x A character scalar: the candidate label (without the `tbl-`
#'   prefix).
#' @returns `x`, invisibly, if valid; otherwise throws.
#' @keywords internal
validate_label <- function(x) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop("`label` must be a non-missing, non-empty character scalar.", call. = FALSE)
  }
  if (grepl("^tbl-", x)) {
    stop(
      sprintf("`label` must not include the 'tbl-' prefix (got %s); it is added automatically.", sQuote(x)),
      call. = FALSE
    )
  }
  if (!grepl(.valid_label_regex, x)) {
    stop(
      sprintf("`label` must contain only letters, digits, '-', and '_' (got %s).", sQuote(x)),
      call. = FALSE
    )
  }
  invisible(x)
}

# A deterministic base-31 rolling hash, reduced mod 2^24 and formatted as 6
# hex digits. Not cryptographic; only needs to be stable and low-collision
# for the caption text of one report's tables.
.label_hash <- function(x) {
  bytes <- utf8ToInt(enc2utf8(x))
  h <- 0
  for (b in bytes) {
    h <- (h * 31 + b) %% 16777216
  }
  sprintf("%06x", as.integer(h))
}

.slugify_caption <- function(x) {
  s <- tolower(enc2utf8(x))
  s <- gsub("[^a-z0-9]+", "-", s)
  s <- gsub("^-+|-+$", "", s)
  if (nchar(s) > 40) {
    s <- substr(s, 1, 40)
    s <- gsub("-+$", "", s)
  }
  s
}

#' Derive a stable Quarto label from a caption
#'
#' Combines a slugified caption with a short deterministic hash of the full
#' caption text, so re-rendering the same caption always produces the same
#' label (no randomness), while two different captions that slugify the same
#' way (or a caption with no alphanumeric characters) still get distinct,
#' non-empty labels.
#'
#' @param caption A character scalar.
#' @returns A character scalar: a valid label without the `tbl-` prefix.
#' @keywords internal
derive_label <- function(caption) {
  caption <- as.character(caption)
  slug <- .slugify_caption(caption)
  hash <- .label_hash(caption)
  if (nzchar(slug)) paste0(slug, "-", hash) else hash
}

# Typst markup-significant characters (and, for the "markdown" backend, the
# same set of Pandoc-markdown-significant characters -- the two coincide
# here). Order matters: the backslash must be escaped first, so that the
# backslashes introduced by escaping the other characters are not themselves
# re-escaped.
.typst_specials <- c("\\", "*", "_", "#", "@", "$", "<", ">", "`", "[", "]")

#' Escape Typst/Pandoc-markdown-significant characters
#'
#' Backslash-escapes each of `* _ # @ $ < > \ \` [ ]` so that it renders as a
#' literal character rather than being interpreted as markup, whether the
#' text is embedded in the surrounding Quarto/Pandoc markdown (captions) or
#' handed to `knitr::kable()` / `tinytable::tt()`, whose output is itself
#' parsed as markdown or Typst source respectively. Verified against Quarto
#' 1.9.37 + Typst 0.14.2: `gt` and `flextable` already escape their own cell
#' content on the way to Typst, so this function is applied to captions
#' always, and to cell text only for the "markdown" and "tinytable" backends
#' (see `render_backend_table()`); applying it to `gt`/`flextable` output
#' would double-escape.
#'
#' @param x A character vector.
#' @returns `x` with each special character backslash-escaped.
#' @keywords internal
escape_typst <- function(x) {
  for (ch in .typst_specials) {
    x <- gsub(ch, paste0("\\", ch), x, fixed = TRUE)
  }
  x
}

# Apply `escape_typst()` to every character/factor column of a data.frame
# (numeric/logical/Date columns cannot contain Typst-significant characters).
escape_typst_df <- function(x) {
  for (col in names(x)) {
    if (is.character(x[[col]])) {
      x[[col]] <- escape_typst(x[[col]])
    } else if (is.factor(x[[col]])) {
      levels(x[[col]]) <- escape_typst(levels(x[[col]]))
    }
  }
  x
}
