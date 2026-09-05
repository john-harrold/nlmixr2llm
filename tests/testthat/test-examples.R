# Execute the fenced R code blocks shipped in the agent and skill markdown.
# See helper-examples.R for the fixture and the opt-in switch.

test_that("every bundled markdown file has balanced code fences", {
  for (f in example_source_files()) {
    expect_no_error(extract_code_blocks(f), message = example_label(f))
  }
})

test_that("skip list only names blocks that exist", {
  blocks <- do.call(rbind, lapply(example_source_files(), extract_code_blocks))
  keys <- paste0(blocks$file, "#", blocks$index)
  expect_true(all(names(example_skips) %in% keys),
              info = paste(setdiff(names(example_skips), keys), collapse = ", "))
})

test_that("bash blocks in the agent run cleanly", {
  skip_on_cran()
  skip_if(Sys.which("Rscript") == "", "Rscript not on PATH")
  blocks <- do.call(rbind, lapply(example_source_files(), extract_code_blocks))
  bash <- blocks[blocks$lang == "bash", , drop = FALSE]
  expect_gt(nrow(bash), 0)
  for (i in seq_len(nrow(bash))) {
    status <- system(bash$code[i], ignore.stdout = TRUE, ignore.stderr = TRUE)
    expect_identical(status, 0L,
                     info = sprintf("%s#%d", bash$file[i], bash$index[i]))
  }
})

# One test per R block so failures are attributed to a specific snippet.
# The fixture (a real SAEM fit) is built once per file run, only when enabled.
examples_enabled <- isTRUE(as.logical(Sys.getenv("NLMIXR2LLM_RUN_EXAMPLES", "false"))) &&
  !identical(Sys.getenv("NOT_CRAN"), "false") &&
  all(vapply(example_packages, requireNamespace, logical(1), quietly = TRUE))

if (!examples_enabled) {
  test_that("skill code examples", {
    skip_unless_examples_enabled()
  })
} else {
  fixture <- example_fixture_env()
  overrides <- lapply(example_block_overrides(fixture), function(f) f())
  root_workdir <- tempfile("nlmixr2llm-examples-")
  dir.create(root_workdir)

  blocks <- do.call(rbind, lapply(example_source_files(), extract_code_blocks))
  blocks <- blocks[blocks$lang == "r", , drop = FALSE]

  for (i in seq_len(nrow(blocks))) {
    block <- blocks[i, ]
    key <- paste0(block$file, "#", block$index)
    test_that(sprintf("%s (line %d) runs", key, block$line), {
      if (key %in% names(example_skips)) {
        skip(example_skips[[key]])
      }
      workdir <- file.path(root_workdir, gsub("[^A-Za-z0-9]+", "_", block$file))
      dir.create(workdir, showWarnings = FALSE, recursive = TRUE)
      result <- NULL
      expect_no_error(
        result <- run_example_block(block, fixture, workdir, overrides)
      )
      bad <- unexpected_warnings(attr(result, "warnings"), key)
      expect_length(bad, 0)
      if (length(bad)) cat("\nUnexpected warnings in ", key, ":\n  ",
                           paste(bad, collapse = "\n  "), "\n", sep = "")
    })
  }
}
