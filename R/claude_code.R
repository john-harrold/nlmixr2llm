#' Install agents and skills into Claude Code
#'
#' Copies the bundled agent and skill content into the location Claude Code
#' reads it from. The single combined ecosystem agent becomes
#' `<root>/agents/nlmixr2verse.md` (installed regardless of `tasks`, since it
#' spans the whole ecosystem); each selected task's skill becomes
#' `<root>/skills/<task>/SKILL.md` plus its supporting reference files (see
#' [list_skill_files()]).
#'
#' Installed files are recorded in a manifest (`<root>/.nlmixr2llm-manifest`).
#' When `prune = TRUE` (the default), re-installing after a package upgrade
#' deletes files this package installed previously but no longer ships (for
#' example the per-package skills that predated the task-oriented skills). Only
#' files nlmixr2llm itself created are ever removed; your own agents and skills
#' are never touched. Pruning is keyed off the full current content set, so
#' selecting a subset with `tasks` does **not** prune the skills of tasks you
#' left out.
#'
#' For `scope = "user"` (which writes under your home directory) the function
#' asks for confirmation in interactive sessions before writing. Non-interactive
#' callers proceed without prompting; set `options(nlmixr2llm.consent = TRUE)` to
#' pre-approve in an interactive setup script.
#'
#' @param scope `"user"` writes to `~/.claude/`; `"project"` writes to
#'   `<path>/.claude/`. The user-scope base is `$CLAUDE_CONFIG_DIR` if set,
#'   otherwise the home directory returned by `getOption("nlmixr2llm.home")`
#'   (defaulting to `~`). Setting `options(nlmixr2llm.home = tempdir())`
#'   redirects user-scope writes away from the real home -- used by the package's
#'   own tests so they never touch your home filespace.
#' @param tasks Character vector of tasks whose skills to install. Defaults to
#'   all available tasks (see [list_tasks()]).
#' @param path Project root when `scope = "project"`. Defaults to the current
#'   working directory.
#' @param overwrite If `TRUE`, replace existing files with the same name.
#'   If `FALSE` (default), existing files are kept and a message is shown.
#' @param prune If `TRUE` (default), remove previously installed files that the
#'   current package version no longer ships (tracked via the manifest). Set
#'   `FALSE` to leave them in place.
#' @return Invisibly, a character vector of files written.
#' @export
#' @examples
#' \dontrun{
#' install_claude_code(scope = "user")
#' install_claude_code(scope = "project", tasks = c("simulation", "estimation"))
#' }
install_claude_code <- function(scope = c("user", "project"),
                                tasks = NULL,
                                path = ".",
                                overwrite = FALSE,
                                prune = TRUE) {
  scope <- match.arg(scope)
  tasks <- match_tasks(tasks)

  root <- claude_root(scope, path)
  if (scope == "user" && !confirm_home_write(root)) {
    message("Aborted: no files written.")
    return(invisible(character()))
  }
  dir.create(file.path(root, "agents"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(root, "skills"), recursive = TRUE, showWarnings = FALSE)

  # The agent is ecosystem-wide, so it is always installed; skills follow the
  # selected tasks.
  targets <- claude_targets(list_agents(), tasks)

  written <- character()
  written_rel <- character()
  n_stale <- 0L
  for (i in seq_along(targets$rel)) {
    src <- targets$src[i]
    rel <- targets$rel[i]
    dst <- file.path(root, rel)
    dir.create(dirname(dst), recursive = TRUE, showWarnings = FALSE)
    st <- copy_or_report(src, dst, overwrite)
    if (st == "written") {
      written <- c(written, dst)
      written_rel <- c(written_rel, rel)
    } else if (st == "stale") {
      n_stale <- n_stale + 1L
    }
  }

  # Prune obsolete files this package installed in a previous version.
  universe <- claude_targets(list_agents(), list_skills())$rel
  removed <- sync_manifest(root, universe, written_rel, prune)

  message(sprintf(
    "Installed %d file(s)%s into %s.%s",
    length(written),
    if (length(removed)) sprintf(", pruned %d obsolete", length(removed)) else "",
    root,
    drift_note(n_stale)
  ))
  invisible(written)
}

# Enumerate the (source, relative-destination) file pairs for a Claude Code
# install of the given agents and task skills.
claude_targets <- function(agents, tasks) {
  src <- character()
  rel <- character()
  for (a in agents) {
    src <- c(src, file.path(pkg_path("agents"), paste0(a, ".md")))
    rel <- c(rel, file.path("agents", paste0(a, ".md")))
  }
  for (t in intersect(tasks, list_skills())) {
    src_dir <- file.path(pkg_path("skills"), t)
    for (f in list_skill_files(t)) {
      src <- c(src, file.path(src_dir, f))
      rel <- c(rel, file.path("skills", t, f))
    }
  }
  list(src = src, rel = rel)
}

claude_root <- function(scope, path) {
  if (scope == "user") {
    env <- Sys.getenv("CLAUDE_CONFIG_DIR", unset = NA)
    if (!is.na(env) && nzchar(env)) env else file.path(nlmixr2llm_home(), ".claude")
  } else {
    file.path(normalizePath(path, mustWork = FALSE), ".claude")
  }
}

# Copy `src` to `dst` unless `dst` exists and `overwrite` is FALSE. Returns the
# outcome: "written"; "stale" (skipped because it exists, but its content
# differs from the bundled file -- an update is available); "current" (skipped,
# identical); or "failed".
copy_or_report <- function(src, dst, overwrite) {
  if (file.exists(dst) && !overwrite) {
    if (files_differ(src, dst)) {
      message(sprintf("  out of date (overwrite = TRUE to refresh): %s", dst))
      return("stale")
    }
    message(sprintf("  up to date: %s", dst))
    return("current")
  }
  ok <- file.copy(src, dst, overwrite = overwrite)
  if (!ok) {
    warning(sprintf("Failed to write %s", dst))
    return("failed")
  }
  "written"
}
