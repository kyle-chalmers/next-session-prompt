# next-session-prompt Project Instructions

IMPORTANT: Everything in this repo is public-facing. Do not place secrets, PII,
or recording/preparation notes here. Owner-specific and internal-only material
goes in `.internal/` (gitignored). When in doubt, keep it out of the published
tree.

## What this is

A single Claude Code skill (`skills/next-session-prompt/`) that captures a
working session into a resume prompt under `prompts/` in the user's current
repo. See `README.md` for the user-facing description and
`docs/superpowers/specs/` for the design.

## Layout

- `skills/next-session-prompt/SKILL.md`: the skill (source of truth)
- `scripts/setup.sh`: idempotent symlink installer into `~/.claude/skills/`
- `docs/superpowers/`: spec and implementation plan
- `.internal/`: owner-only, gitignored

## Editing the skill

Edits to `skills/next-session-prompt/SKILL.md` take effect immediately because
`setup.sh` symlinks it into `~/.claude/skills/`. Commit and push when behavior
changes. Keep frontmatter to `name` and `description` only, and write the
`description` as a folded block scalar (`>-`) so it parses under both Claude and
Codex.
