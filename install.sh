#!/usr/bin/env bash
set -euo pipefail

# One-line global installer for the next-session-prompt Claude Code skill.
# No clone required: fetches SKILL.md straight into ~/.claude/skills/.
#
#   curl -fsSL https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main/install.sh | bash
#
# Override the destination with CLAUDE_SKILLS_DIR if your skills live elsewhere.

REPO_RAW="https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
DEST_DIR="$SKILLS_DIR/next-session-prompt"

# Don't clobber a symlinked dev install (created by scripts/setup.sh).
if [ -L "$DEST_DIR" ]; then
  echo "next-session-prompt is already linked (dev install) at $DEST_DIR; nothing to do."
  exit 0
fi

mkdir -p "$DEST_DIR"
curl -fsSL "$REPO_RAW/skills/next-session-prompt/SKILL.md" -o "$DEST_DIR/SKILL.md"

echo "Installed next-session-prompt -> $DEST_DIR/SKILL.md"
echo "Start a new Claude Code session, then run /next-session-prompt"
