# AGENTS.md

Instructions for any AI agent or contributor working in this repository. Read this before changing anything.

## What this repo is

A collection of custom agents (currently one: **Ian**, a stand-in for Ian that explains his working style and formats). Each agent ships in several tool-specific formats that are generated from a single source.

## Layout

| Path                                                         | Role                                                                                                                             | Edit by hand?     |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `src/<agent>.md`                                             | Shared body for an agent. The source of truth.                                                                                   | Yes               |
| `scripts/sync-agents.py`                                     | Generator. Holds the per-target frontmatter.                                                                                     | Yes               |
| `.github/agents/<agent>.agent.md`                            | VS Code / GitHub Copilot custom agent                                                                                            | **No, generated** |
| `.claude/agents/<agent>.md`                                  | Claude Code subagent                                                                                                             | **No, generated** |
| `skills/<agent>/SKILL.md`                                    | Gemini skill (web app upload)                                                                                                    | **No, generated** |
| `.githooks/pre-commit`, `.github/workflows/check-agents.yml` | Fail on drift between source and generated files                                                                                 | Rarely            |
| `.github/workflows/release.yml`                              | On merge to `main`, publish a release whose zip holds only the generated agent files, grouped in a folder per agent (`<agent>/`) | Rarely            |

## Rules

1. **Never edit a generated file.** Change `src/<agent>.md` (body) or the frontmatter in `scripts/sync-agents.py`, then regenerate.
2. **Always regenerate and verify before finishing:**
   - Regenerate: `docker compose run --rm sync`
   - Verify: `docker compose run --rm check`
   - Without Docker: `python3 scripts/sync-agents.py` and `python3 scripts/sync-agents.py --check` (standard library only).
3. **One agent, one source, all targets.** A change is not done until every target is regenerated and `--check` passes.
4. **Do not invent Ian's opinions.** Add a preference to `src/ian.md` only when Ian has stated it. Unknown areas are handled by the "Open Questions" output format in the agent, not by guessing.
5. **Keep the disclaimer.** Every generated agent must state that it is an AI stand-in and not Ian.

## Source format (`src/<agent>.md`)

- Plain Markdown with no frontmatter. Frontmatter is added per target by the generator.
- The leading HTML comment is stripped from the output; use it for notes to contributors.
- Block directives limit content to specific targets (`vscode`, `claude`, `gemini`). Each directive is its own line:
  - Open with a comment line reading `only: vscode, claude`.
  - Close with a comment line reading `/only`.
  - Blocks cannot be nested.
- Placeholders in double braces are replaced per target: `kind` (agent or skill), `workspace` (workspace or project), `where` (where preferences are written). An unknown placeholder fails the build.
- Number ordered lists as `1.` on every item so conditional blocks do not break numbering.

## Per-target frontmatter

Fields differ by tool. Do not copy fields between targets.

| Target                    | Required              | Notable fields                                                                                 |
| ------------------------- | --------------------- | ---------------------------------------------------------------------------------------------- |
| VS Code (`.agent.md`)     | `description`         | `name`, `argument-hint`, `tools` (aliases such as `read`, `edit`), `model`, `reasoning-effort` |
| Claude Code (subagent)    | `name`, `description` | `tools` (comma list such as `Read, Grep`), `model` (alias or full ID), `effort`                |
| Gemini skill (`SKILL.md`) | `name`, `description` | No tool, model, or effort fields                                                               |

- Quote any `description` that contains `: `, or the YAML will not parse.
- Descriptions are how each tool decides when to use the agent. Keep them specific and trigger-word rich.
- Docs: [VS Code custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents), [Claude Code subagents](https://code.claude.com/docs/en/sub-agents), [Gemini skills](https://support.google.com/gemini/answer/17094296).

## Adding a new agent

The generator currently handles a single agent (`src/ian.md`). To add another:

1. Create `src/<new-agent>.md` following the source format above.
2. Generalize `scripts/sync-agents.py` to loop over agents, each with its own targets and frontmatter. Keep `--check` covering every generated file.
3. Add the new generated paths to the table above and to the README.
4. Regenerate, run the check, and confirm the pre-commit hook and CI both pass.

## Conventions

- **Commits:** Conventional Commits with an emoji, for example `✨ feat(agents): add reviewer agent`.
- **Pull requests:** Open with an Executive Summary (Why and How), then the full scope of changes, then testing and rollout.
- **Naming:** kebab-case, unless a tool or platform standard requires otherwise (for example `README.md`, `AGENTS.md`, `Dockerfile`, `SKILL.md`).
- **Diagrams:** Mermaid code blocks.
- **GitHub tasks:** Prefer the `gh` CLI.
- **Tooling:** Scripts are Python. Local build, run, and test go through Docker Compose.
