#!/usr/bin/env bash
set -euo pipefail

# One-line global installer for the next-session-prompt coding-agent skill.
# No clone required: fetches SKILL.md straight into local agent skill dirs.
#
#   curl -fsSL https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main/install.sh | bash
#
# Defaults install to Claude Code, Codex, and Gemini/Antigravity-style skill dirs.
# Override targets with NEXT_SESSION_PROMPT_AGENTS=claude,codex,gemini.
# Override destinations with CLAUDE_SKILLS_DIR, CODEX_SKILLS_DIR, or GEMINI_SKILLS_DIR.
# Add custom destinations with EXTRA_SKILLS_DIRS, colon-separated.

REPO_RAW="https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main"
AGENTS="${NEXT_SESSION_PROMPT_AGENTS:-claude,codex,gemini}"

install_to_dir() {
  local skills_dir="$1"
  local dest_dir="$skills_dir/next-session-prompt"

  # Don't clobber a symlinked dev install (created by scripts/setup.sh).
  if [ -L "$dest_dir" ]; then
    echo "next-session-prompt is already linked (dev install) at $dest_dir; skipping."
    return
  fi

  mkdir -p "$dest_dir"
  curl -fsSL "$REPO_RAW/skills/next-session-prompt/SKILL.md" -o "$dest_dir/SKILL.md"
  echo "installed next-session-prompt -> $dest_dir/SKILL.md"
}

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

IFS=',' read -r -a agent_list <<< "$AGENTS"
for agent in "${agent_list[@]}"; do
  agent="${agent//[[:space:]]/}"
  [ -n "$agent" ] || continue
  skills_dir="$(skills_dir_for_agent "$agent")"
  install_to_dir "$skills_dir"
done

if [ -n "${EXTRA_SKILLS_DIRS:-}" ]; then
  IFS=':' read -r -a extra_dirs <<< "$EXTRA_SKILLS_DIRS"
  for skills_dir in "${extra_dirs[@]}"; do
    [ -n "$skills_dir" ] || continue
    install_to_dir "$skills_dir"
  done
fi

echo "Done. Start a new agent session, then invoke next-session-prompt by name."
