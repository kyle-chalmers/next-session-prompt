# next-session-prompt Project Instructions

IMPORTANT: Everything in this repo is public-facing. Do not place secrets, PII,
or recording/preparation notes here. Owner-specific and internal-only material
goes in `.internal/` (gitignored). When in doubt, keep it out of the published
tree.

## What this is

A single portable coding-agent skill (`skills/next-session-prompt/`) that
captures a working session into a resume prompt under `prompts/` in the user's
current repo. See `README.md` for the user-facing description and
`docs/superpowers/specs/` for the original design.

## Layout

- `skills/next-session-prompt/SKILL.md`: the skill (source of truth)
- `install.sh`: one-line installer that copies the skill into agent skill dirs
- `scripts/setup.sh`: idempotent symlink installer into agent skill dirs
- `AGENTS.md` / `GEMINI.md`: project guidance for non-Claude agents
- `docs/superpowers/`: spec and implementation plan
- `.internal/`: owner-only, gitignored

## Editing the skill

Edits to `skills/next-session-prompt/SKILL.md` take effect immediately because
`setup.sh` symlinks it into local agent skill dirs. Commit and push when
behavior changes. Keep frontmatter to `name` and `description` only, and write
the `description` as a folded block scalar (`>-`) so it parses under Claude,
Codex, and other simple Markdown skill loaders.

The default supported install targets are Claude Code, Codex, and
Gemini/Antigravity-style skill directories. Unknown agents should consume
`skills/next-session-prompt/SKILL.md` as a plain Markdown prompt unless they
document a compatible skill directory.
