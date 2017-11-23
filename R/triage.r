methods::setMethod(jsonlite:::asJSON, "call", function(x, ...) {
  jsonlite:::asJSON(toString(x), ...)
})

#' Collect and export triage info
#'
#' Package-level function that enales direct calling & naming of an output file.
#'
#' You can either:
#'
#'     source(system.file("scripts", "triage.R", package="triage"))
#'
#' for automatic usage or use this function like so:
#'
#'     triage::triage()
#'
#' and have the flexibility of supplying parameters.
#'
#' The following bits are colected and --- where possible --- tidied:
#'
#' - environment variables
#' - options settings
#' - R version & platform information
#' - Base packages
#' - Other packages
#' - Loaded pacakges
#' - Object names, sizes and classes in the global environement, including hidden ones
#'
#' NOTE: This is a _dangerous_ function since the output may contain **sensitive data**,
#' including, but not limited to, API keys or other credentials. Do not share carelessly.
#'
#' @md
#' @param serialize_to output format; `json` or `rds`
#' @param out if not `NULL` the output file the triage info will be stored to
#' @param warn enable/disable sensitive data warning (default: `TRUE`)
#' @export
#' @examples
#' triage::triage()
triage <- function(serialize_to = c("json", "rds"), out=NULL, warn=TRUE) {

  serialize_to <- match.arg(serialize_to, c("json", "rds"))

  if (is.null(out)) {
    tempfile(
      pattern = "triage_",
      fileext = sprintf(".%s", serialize_to)
    ) -> out
  }

  env <- Sys.getenv()
  opt <- options()
  ses <- sessionInfo()
  lapply(objects(envir = .GlobalEnv, all.names = TRUE), function(x) {
    data.frame(
      name = x,
      class = class(.GlobalEnv[[x]]),
      size = unclass(object.size(.GlobalEnv[[x]])),
      stringsAsFactors = FALSE
    )
  }) -> obj

  mk_df <- function(p, x) {

    vals <- unname(x)

    .ser <- function(x) {
      if ((!is.character(x)) | (length(x) > 1)) {
        if (class(x) %in% c("call", "function")) {
          as.character(jsonlite::toJSON(x))
        } else {
          toString(x)
        }
      } else {
        x
      }
    }

    data.frame(
      place = p,
      key = names(x),
      val = sapply(vals, .ser),
      stringsAsFactors = FALSE
    )

  }

  rbind_fill <- function(...) {
    dfs <- list(...)
    cols <- Reduce(union, lapply(dfs, colnames))
    do.call(rbind, lapply(dfs, function(df) {
      df_cols <- setdiff(cols, colnames(df))
      df[,df_cols] <- NA
      df
    }))
  }

  as.data.frame.packageDescription <- function(x, ...) {
    nm <- names(x)
    vl <- unclass(unlist(x, use.names = FALSE))
    loc <- attr(x, "file")
    cbind.data.frame(setNames(as.list(c(vl, loc)), c(nm, "loc")), stringsAsFactors=FALSE)
  }

  list(
    environemnt = mk_df("environment", unclass(env)),
    options = mk_df("options", opt),
    r_version = mk_df("r_version", ses$R.version),
    platform = mk_df("platform", ses[c("platform", "locale", "running", "matprod", "BLAS", "LAPACK")]),
    base = data.frame(place = "base_pkgs", key = ses$basePkgs, val = ses$basePkgs, stringsAsFactors=FALSE),
    other_pkgs = Reduce(rbind_fill, lapply(ses$otherPkgs, as.data.frame.packageDescription)),
    loaded_pkgs = Reduce(rbind_fill, lapply(ses$loadedOnly, as.data.frame.packageDescription)),
    objects = Reduce(rbind_fill, obj)
  ) -> x

  if (serialize_to == "json") {
    writeLines(
      jsonlite::toJSON(x, pretty = TRUE, force = TRUE),
      out
    )
  } else {
    saveRDS(x, out)
  }

  if (warn) warning("NOTE: The triage file may contain sensitive data in R data structures, including API keys.
Review contents carefully before sharing.")
  message(sprintf("Triage data: [%s]", out))

  invisible(NULL)

}
