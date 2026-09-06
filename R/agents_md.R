#' Install agents and skills as a project-root AGENTS.md
#'
#' Writes a single `AGENTS.md` at the project root in the format defined by
#' the cross-tool agents.md specification (`https://agents.md`). The file is
#' read by many tools that follow that convention, including OpenAI Codex
#' CLI, Cursor, Aider, GitHub Copilot, Zed, Warp, Jules, and Devin.
#'
#' For Codex-specific installation that also supports the user-level
#' `~/.codex/AGENTS.md` location and warns about the Codex byte cap, see
#' [install_codex()]. For Claude Code's separate skill/agent tree, see
#' [install_claude_code()].
#'
#' @param path Project root. Defaults to the current working directory.
#' @param tasks Character vector of tasks whose skills to include. Defaults to
#'   all available tasks (see [list_tasks()]).
#' @param mode How to handle an existing file: `"write"` (default),
#'   `"append"`, or `"error"`.
#' @param include Which content to include: `"both"` (default), `"agents"`,
#'   or `"skills"`.
#' @param references If `TRUE`, also include each skill's supporting reference
#'   files (see [list_skill_files()]). Defaults to `FALSE`.
#' @return Invisibly, the path written.
#' @export
#' @examples
#' \dontrun{
#' install_agents_md(path = ".", tasks = c("simulation", "estimation"))
#' }
install_agents_md <- function(path = ".",
                              tasks = NULL,
                              mode = c("write", "append", "error"),
                              include = c("both", "agents", "skills"),
                              references = FALSE) {
  install_codex(
    scope = "project",
    tasks = tasks,
    path = path,
    mode = mode,
    include = include,
    references = references
  )
}
