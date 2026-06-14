#!/usr/bin/env bash
set -euo pipefail

# Idempotent installer: symlink each skill in skills/ into ~/.claude/skills/.
# Safe to re-run. Replaces existing symlinks; refuses to clobber real dirs.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

mkdir -p "$SKILLS_DEST"

for skill in "$SKILLS_SRC"/*/; do
  skill="${skill%/}"
  name="$(basename "$skill")"
  link="$SKILLS_DEST/$name"

  if [ -L "$link" ]; then
    rm "$link"
  elif [ -e "$link" ]; then
    echo "skip: $link exists and is not a symlink" >&2
    continue
  fi

  ln -s "$skill" "$link"
  echo "linked $name -> $skill"
done

echo "Done. Restart Claude Code or start a new session to load the skill."
