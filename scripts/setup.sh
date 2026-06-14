#!/usr/bin/env bash
set -euo pipefail

# Idempotent contributor installer: symlink each skill in skills/ into local
# agent skill dirs. Safe to re-run. Replaces existing symlinks; refuses to
# clobber real dirs.
#
# Defaults install to Claude Code, Codex, and Gemini/Antigravity-style skill dirs.
# Override targets with NEXT_SESSION_PROMPT_AGENTS=claude,codex,gemini.
# Override destinations with CLAUDE_SKILLS_DIR, CODEX_SKILLS_DIR, or GEMINI_SKILLS_DIR.
# Add custom destinations with EXTRA_SKILLS_DIRS, colon-separated.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
AGENTS="${NEXT_SESSION_PROMPT_AGENTS:-claude,codex,gemini}"

skills_dir_for_agent() {
  case "$1" in
    claude) printf '%s\n' "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}" ;;
    codex) printf '%s\n' "${CODEX_SKILLS_DIR:-$HOME/.codex/skills}" ;;
    gemini) printf '%s\n' "${GEMINI_SKILLS_DIR:-$HOME/.gemini/antigravity-cli/skills}" ;;
    *)
      echo "unknown agent target: $1" >&2
      echo "valid targets: claude,codex,gemini" >&2
      return 1
      ;;
  esac
}

link_skills_into() {
  local skills_dest="$1"

  mkdir -p "$skills_dest"

  for skill in "$SKILLS_SRC"/*/; do
    skill="${skill%/}"
    name="$(basename "$skill")"
    link="$skills_dest/$name"

    if [ -L "$link" ]; then
      rm "$link"
    elif [ -e "$link" ]; then
      echo "skip: $link exists and is not a symlink" >&2
      continue
    fi

    ln -s "$skill" "$link"
    echo "linked $name -> $skill"
  done
}

IFS=',' read -r -a agent_list <<< "$AGENTS"
for agent in "${agent_list[@]}"; do
  agent="${agent//[[:space:]]/}"
  [ -n "$agent" ] || continue
  skills_dir="$(skills_dir_for_agent "$agent")"
  link_skills_into "$skills_dir"
done

if [ -n "${EXTRA_SKILLS_DIRS:-}" ]; then
  IFS=':' read -r -a extra_dirs <<< "$EXTRA_SKILLS_DIRS"
  for skills_dir in "${extra_dirs[@]}"; do
    [ -n "$skills_dir" ] || continue
    link_skills_into "$skills_dir"
  done
fi

echo "Done. Restart your coding agent or start a new session to load the skill."
