# Changelog

## nlmixr2llm 0.1.0

- Initial version.
- Ships a single combined `nlmixr2verse` agent spanning the nlmixr2
  pharmacometrics ecosystem (`rxode2`, `nlmixr2`, `nonmem2rx`,
  `monolix2rx`, `babelmixr2`), plus one skill per package.
- Accessor functions:
  [`list_packages()`](https://john-harrold.github.io/nlmixr2llm/reference/list_packages.md),
  [`list_agents()`](https://john-harrold.github.io/nlmixr2llm/reference/list_agents.md),
  [`list_skills()`](https://john-harrold.github.io/nlmixr2llm/reference/list_skills.md),
  [`get_agent()`](https://john-harrold.github.io/nlmixr2llm/reference/get_agent.md),
  [`get_skill()`](https://john-harrold.github.io/nlmixr2llm/reference/get_skill.md),
  and
  [`system_prompt()`](https://john-harrold.github.io/nlmixr2llm/reference/system_prompt.md)
  for use as a system prompt with any LLM client.
- Installer functions write the content into the locations expected by
  Claude Code
  ([`install_claude_code()`](https://john-harrold.github.io/nlmixr2llm/reference/install_claude_code.md)),
  OpenAI Codex CLI
  ([`install_codex()`](https://john-harrold.github.io/nlmixr2llm/reference/install_codex.md)),
  Positron Assistant
  ([`install_positron()`](https://john-harrold.github.io/nlmixr2llm/reference/install_positron.md)),
  and any tool that reads `AGENTS.md`
  ([`install_agents_md()`](https://john-harrold.github.io/nlmixr2llm/reference/install_agents_md.md)).
  Multi-file installers track what they write in a manifest and can
  prune content the package no longer ships.
- [`nlmixr2llm_status()`](https://john-harrold.github.io/nlmixr2llm/reference/nlmixr2llm_status.md)
  reports whether the content installed into each target is up to date
  with the package.
