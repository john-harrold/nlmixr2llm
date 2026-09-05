#' Report whether installed coding-agent content is up to date
#'
#' Compares the agent and skill content this version of `nlmixr2llm` bundles
#' against the copies previously installed into each supported coding-agent
#' target, so you can tell when an upgrade of the package ships newer agents or
#' skills than the files those tools are currently loading. The installers write
#' **independent copies**, so they do not change when the package is upgraded
#' until you re-install.
#'
#' Targets checked:
#' * **Claude Code** (`~/.claude/` user scope and `<path>/.claude/` project
#'   scope) -- discrete agent/skill files, compared by content.
#' * **Codex / `AGENTS.md`** (`~/.codex/AGENTS.md` and `<path>/AGENTS.md`, the
#'   latter shared with [install_agents_md()]).
#' * **Positron** `agents.md` (`<path>/agents.md`) and per-task
#'   `*.instructions.md` files (`<path>/.github/instructions/`).
#'
#' Concatenated single-file targets carry an embedded version stamp, so they are
#' compared by the package version recorded at install time; Claude Code files
#' are compared by content. Each file is classified `"current"`, `"outdated"`,
#' or `"not installed"`. Only targets that actually have installed content are
#' mentioned in the printed summary.
#'
#' When the package is attached interactively, it runs this check automatically
#' (read-only) and prints a one-line notice if any installed copy is out of
#' date. Disable that startup check with `options(nlmixr2llm.startup_check =
#' FALSE)`.
#'
#' @param path Project root used for project-scoped targets. Defaults to the
#'   current working directory. User-scoped targets (`~/.claude`, `~/.codex`)
#'   are always checked at their fixed locations.
#' @param quiet If `TRUE`, suppress the printed summary and only return the data
#'   frame.
#' @return Invisibly, a data frame with columns `target`, `location`, `item`,
#'   `status`, and `refresh` (the command that would refresh that target).
#' @seealso [install_claude_code()], [install_codex()], [install_positron()]
#' @export
#' @examples
#' \dontrun{
#' nlmixr2llm_status()
#' }
nlmixr2llm_status <- function(path = ".", quiet = FALSE) {
  rows <- rbind(
    claude_status_rows(path),
    file_version_rows(path),
    positron_instruction_rows(path)
  )
  if (!quiet) {
    report_status(rows)
  }
  invisible(rows)
}

# Claude Code: discrete files, compared by content against the bundle.
claude_status_rows <- function(path) {
  targets <- claude_targets(list_agents(), list_skills())
  do.call(rbind, lapply(c("user", "project"), function(s) {
    root <- claude_root(s, path)
    dst <- file.path(root, targets$rel)
    status <- vapply(seq_along(dst), function(i) {
      if (!file.exists(dst[i])) {
        "not installed"
      } else if (files_differ(targets$src[i], dst[i])) {
        "outdated"
      } else {
        "current"
      }
    }, character(1))
    data.frame(
      target = sprintf("Claude Code (%s)", s),
      location = root,
      item = targets$rel,
      status = status,
      refresh = sprintf(
        'install_claude_code(scope = "%s", overwrite = TRUE)', s
      ),
      stringsAsFactors = FALSE
    )
  }))
}

# Concatenated single-file targets: compared by the embedded version stamp.
file_version_rows <- function(path) {
  ws <- normalizePath(path, mustWork = FALSE)
  specs <- list(
    list(
      target = "Codex (user)",
      file = codex_path("user", path),
      refresh = 'install_codex(scope = "user", mode = "write")'
    ),
    list(
      target = "Codex / AGENTS.md (project)",
      file = codex_path("project", path),
      refresh = 'install_codex(scope = "project", mode = "write")'
    ),
    list(
      target = "Positron agents.md (project)",
      file = file.path(ws, "agents.md"),
      refresh = 'install_positron(style = "agents_md", overwrite = TRUE)'
    )
  )
  rows <- do.call(rbind, lapply(specs, function(sp) {
    data.frame(
      target = sp$target,
      location = sp$file,
      item = basename(sp$file),
      status = version_status(sp$file),
      refresh = sp$refresh,
      stringsAsFactors = FALSE
    )
  }))

  # On case-insensitive filesystems (macOS, Windows) Codex's AGENTS.md and
  # Positron's agents.md are the *same* file; collapse rows that resolve to one
  # real path so it isn't reported twice. Non-existent files stay distinct.
  canon <- vapply(seq_len(nrow(rows)), function(i) {
    f <- rows$location[i]
    if (file.exists(f)) normalizePath(f, mustWork = FALSE) else paste0(" ", i)
  }, character(1))
  rows[!duplicated(canon), , drop = FALSE]
}

# Positron per-task instruction files: stamped, compared by version.
positron_instruction_rows <- function(path) {
  dir <- file.path(normalizePath(path, mustWork = FALSE),
                   ".github", "instructions")
  refresh <- 'install_positron(style = "instructions", overwrite = TRUE)'
  files <- list.files(dir, pattern = "\\.instructions\\.md$", full.names = TRUE)
  if (!length(files)) {
    return(data.frame(
      target = "Positron instructions (project)", location = dir,
      item = NA_character_, status = "not installed", refresh = refresh,
      stringsAsFactors = FALSE
    ))
  }
  data.frame(
    target = "Positron instructions (project)",
    location = dir,
    item = basename(files),
    status = vapply(files, version_status, character(1)),
    refresh = refresh,
    stringsAsFactors = FALSE
  )
}

version_status <- function(file) {
  v <- stamp_version(file)
  if (is.na(v)) {
    "not installed"                       # absent, or not written by us
  } else if (identical(v, as.character(utils::packageVersion("nlmixr2llm")))) {
    "current"
  } else {
    "outdated"
  }
}

# Compose a brief startup note when any installed target is out of date, or
# NULL when everything is current / nothing is installed. Factored out of
# .onAttach() (see zzz.R) so it can be tested without an interactive session.
startup_drift_message <- function(status) {
  outdated <- status[status$status == "outdated", , drop = FALSE]
  if (!nrow(outdated)) {
    return(NULL)
  }
  targets <- unique(outdated$target)
  paste0(
    "nlmixr2llm: installed content is out of date in ", length(targets),
    " location(s) (", paste(targets, collapse = ", "), ").\n",
    "Run nlmixr2llm_status() to see details and the command to refresh each."
  )
}

report_status <- function(rows) {
  ver <- as.character(utils::packageVersion("nlmixr2llm"))
  reported <- FALSE

  for (g in unique(rows$target)) {
    d <- rows[rows$target == g, ]
    present <- d[d$status %in% c("current", "outdated"), ]
    if (!nrow(present)) {
      next                                # nothing of ours installed here
    }
    reported <- TRUE
    n_out <- sum(present$status == "outdated")
    n_cur <- sum(present$status == "current")
    # "not yet installed" is only meaningful for Claude Code, where the target
    # is a set of files some of which may be missing (new content / subset).
    n_new <- if (startsWith(g, "Claude Code")) sum(d$status == "not installed") else 0L

    if (n_out > 0 || n_new > 0) {
      message(sprintf(
        "nlmixr2llm %s -- %s (%s): %d of %d file(s) out of date%s. Refresh: %s",
        ver, g, d$location[1], n_out, n_out + n_cur,
        if (n_new > 0) sprintf(", %d not yet installed", n_new) else "",
        d$refresh[1]
      ))
    } else {
      message(sprintf(
        "nlmixr2llm %s -- %s (%s): all %d file(s) up to date.",
        ver, g, d$location[1], n_cur
      ))
    }
  }

  if (!reported) {
    message(sprintf(
      paste0("nlmixr2llm %s: no installed content found for any target ",
             "(Claude Code, Codex, AGENTS.md, Positron). ",
             "Install with one of the install_* functions."),
      ver
    ))
  }
}
