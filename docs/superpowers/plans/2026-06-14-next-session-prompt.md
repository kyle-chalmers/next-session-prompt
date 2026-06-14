# next-session-prompt Implementation Plan

> Current implementation note: the skill started as Claude Code-only, but now supports Claude Code, Codex, and Gemini/Antigravity-style skill directories. `install.sh` copies the skill for global installs, and `scripts/setup.sh` symlinks it for contributor installs.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a public GitHub repo containing a manually-invoked Claude Code skill that captures the current session into one self-describing markdown resume prompt under `prompts/`.

**Architecture:** A single-skill repo following the public-facing pattern (`.internal/` gitignored, public notice in `CLAUDE.md`). The skill is pure instructions (`SKILL.md`); a `setup.sh` symlinks it into `~/.claude/skills/`. No application code, so verification is YAML-parse / symlink / gitignore / secret-audit checks rather than unit tests.

**Tech Stack:** Markdown skill definition, Bash installer, `gh` CLI for repo creation, Ruby (YAML frontmatter validation, already used in kc-content-workspace).

**Repo root:** `~/Development/next-session-prompt` (already created, git initialized on `main`, spec committed at `be4e7c6`).

---

## File Structure

| File | Responsibility |
|------|----------------|
| `.gitignore` | Exclude `.internal/`, `prompts/`, `.DS_Store` |
| `.internal/OWNER_CONFIG.md` | Owner/recording notes — gitignored, never published |
| `skills/next-session-prompt/SKILL.md` | The skill: triggers + procedure + handoff template |
| `scripts/setup.sh` | Idempotent symlink of `skills/*` into `~/.claude/skills/` |
| `README.md` | Public: the problem, install, usage |
| `CLAUDE.md` | Public-facing notice + internalized skill guidance |

---

### Task 1: Repo hygiene — `.gitignore` + `.internal/`

**Files:**
- Create: `~/Development/next-session-prompt/.gitignore`
- Create: `~/Development/next-session-prompt/.internal/OWNER_CONFIG.md`

- [ ] **Step 1: Write `.gitignore`**

```gitignore
# Owner-only, never published
.internal/

# Session handoff artifacts written by the skill (per-repo, ephemeral)
prompts/

# macOS
.DS_Store
```

- [ ] **Step 2: Write `.internal/OWNER_CONFIG.md`**

```markdown
# Owner Config (internal — gitignored)

Owner-specific values and recording notes for this repo. Never published.

- **Owner:** Kyle Chalmers — Kyle Chalmers Data Plus AI (https://www.youtube.com/@kylechalmersdataai)
- **Video:** this repo is the subject of a planned YouTube video on surviving context limits / auto-compact.
- **Secrets:** none required by this skill (it writes local markdown only).
```

- [ ] **Step 3: Verify `.internal/` is ignored**

Run: `cd ~/Development/next-session-prompt && git check-ignore .internal/OWNER_CONFIG.md prompts/`
Expected: both paths printed (meaning git ignores them).

- [ ] **Step 4: Commit**

```bash
cd ~/Development/next-session-prompt
git add .gitignore
git commit -m "chore: gitignore .internal/, prompts/, .DS_Store"
```

(Note: `.internal/OWNER_CONFIG.md` is intentionally NOT committed — it is gitignored.)

---

### Task 2: The skill — `SKILL.md`

**Files:**
- Create: `~/Development/next-session-prompt/skills/next-session-prompt/SKILL.md`

- [ ] **Step 1: Write `SKILL.md`**

````markdown
---
name: next-session-prompt
description: >-
  Use when a working session is running low on context (approaching auto-compact) with unfinished follow-ups, or when the user says "hand off this session", "write a next session prompt", "save this for next time", "I'm running low on context", or invokes /next-session-prompt. Captures the session state into one self-describing markdown resume prompt under prompts/ in the current repo so a fresh session can continue the work without the original conversation.
---

# Next Session Prompt

Capture the current working session into a single markdown file that a fresh
session can read to continue the work. The file IS the resume prompt — there is
no separate resume mode. To continue, the user starts a new session and pastes
the file or says "read `prompts/<file>.md` and continue".

## When to use

- The user is running low on context (heading toward auto-compact) and has
  unfinished follow-ups.
- The user explicitly asks to hand off, save, or write a next-session prompt.

## Procedure

1. **Locate the target repo.**
   Run `git rev-parse --show-toplevel`. If it succeeds, that path is the target
   repo root and the file goes in `<root>/prompts/`. If it fails (not a git
   repo), use the current working directory and tell the user the file is being
   written to `./prompts/` outside any git repo.

2. **Guarantee `prompts/` is gitignored** (only when inside a git repo).
   Check whether `prompts/` is already ignored:
   `git check-ignore prompts >/dev/null 2>&1`.
   If it is NOT ignored, append a line to the repo's root `.gitignore`
   (create the file if absent):

   ```
   prompts/
   ```

   Never commit anything in this step — only edit `.gitignore` if needed and
   leave it staged-or-unstaged for the user to decide.

3. **Derive the filename.**
   - Date: today's date as `YYYY-MM-DD`.
   - Slug: 3-6 kebab-case words naming the session's primary task
     (e.g. `auth-rate-limiting`, `next-session-prompt-skill`).
   - Path: `prompts/YYYY-MM-DD-<slug>.md`.
   - If that file already exists, append `-2`, `-3`, … until the name is free.

4. **Synthesize the handoff** from the conversation. Read back over the session
   and fill every section of the template below with real content. No
   placeholders — if a section is genuinely empty (e.g. nothing running), write
   "None" rather than leaving it blank.

5. **Write the file** and report its path to the user in one line.

## Handoff template

Write the file in second person, addressed to the next session:

```markdown
# Resuming: <task title>

> You are resuming work from a previous session. The earlier conversation is
> gone; this file is your context. Read it, then continue from **Start here**.

## Objective
<What is being worked on and why. 1-3 sentences.>

## Status
- Done: <what is finished>
- In progress: <what is mid-flight>

## Decisions made
- <decision> — <why> (so it is not relitigated)

## Outstanding follow-ups
1. <next thing to do>
2. <then this>
3. <…ordered>

## Current state
- Repo: <path>  |  Branch: <branch>
- Modified files: <paths, or "none">
- Running / external state: <servers, jobs, or "none">
- Relevant paths: <files worth opening first>

## Start here
<The single best first action for the next session.>

## Gotchas
- <non-obvious context that would otherwise be lost, or "none">
```

## Notes

- Write exactly ONE file per invocation.
- Do not commit the handoff file; `prompts/` is gitignored on purpose.
- Keep it tight and scannable — the Outstanding follow-ups list is the core.
````

- [ ] **Step 2: Verify the frontmatter parses (Claude + Codex compatible)**

Run:
```bash
ruby -e 'require "yaml"; f="'"$HOME"'/Development/next-session-prompt/skills/next-session-prompt/SKILL.md"; s=File.read(f); fm=s[/\A---\n(.*?)\n---\n/m,1]; y=YAML.safe_load(fm); raise "missing name" unless y && y["name"]; raise "missing description" unless y["description"]; puts "OK: #{y["name"]}"'
```
Expected: `OK: next-session-prompt`

- [ ] **Step 3: Commit**

```bash
cd ~/Development/next-session-prompt
git add skills/next-session-prompt/SKILL.md
git commit -m "feat: add next-session-prompt skill"
```

---

### Task 3: Installer — `scripts/setup.sh`

**Files:**
- Create: `~/Development/next-session-prompt/scripts/setup.sh`

- [ ] **Step 1: Write `scripts/setup.sh`**

```bash
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
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x ~/Development/next-session-prompt/scripts/setup.sh
```

- [ ] **Step 3: Run it and verify the symlink resolves**

Run:
```bash
~/Development/next-session-prompt/scripts/setup.sh
readlink ~/.claude/skills/next-session-prompt
```
Expected: installer prints `linked next-session-prompt -> …`, and `readlink` prints `…/Development/next-session-prompt/skills/next-session-prompt`.

- [ ] **Step 4: Verify re-run is idempotent (no error, no duplicate)**

Run: `~/Development/next-session-prompt/scripts/setup.sh`
Expected: prints `linked next-session-prompt -> …` again with exit code 0 (it removes and recreates the symlink cleanly).

- [ ] **Step 5: Commit**

```bash
cd ~/Development/next-session-prompt
git add scripts/setup.sh
git commit -m "chore: add idempotent setup.sh skill installer"
```

---

### Task 4: Public-facing docs — `README.md` + `CLAUDE.md`

**Files:**
- Create: `~/Development/next-session-prompt/README.md`
- Create: `~/Development/next-session-prompt/CLAUDE.md`

- [ ] **Step 1: Write `README.md`** (public-facing prose — no em dashes, plain words)

```markdown
# next-session-prompt

A Claude Code skill that saves a working session as a resume prompt so you can
continue in a fresh session without losing the thread.

## The problem

Long sessions hit the context limit and auto-compact. Compaction summarizes
lossily, so outstanding follow-ups, decisions, and the reasoning behind them can
blur or drop. There is no reliable way for the model to watch its own context
percentage and act on it, so the dependable move is to capture the session
yourself right before you run low.

## What it does

Run the skill near the end of a session. It reads the conversation and writes
one markdown file to `prompts/` in your current repo. The file is written as a
prompt addressed to the next session: objective, status, decisions made,
outstanding follow-ups, current state, and the recommended first action. The
`prompts/` folder is gitignored, so handoffs stay local and never get committed.

To continue, open a new session and paste the file, or say
"read `prompts/<file>.md` and continue".

## Install

```bash
git clone https://github.com/<you>/next-session-prompt ~/Development/next-session-prompt
cd ~/Development/next-session-prompt
./scripts/setup.sh
```

`setup.sh` symlinks the skill into `~/.claude/skills/`. Start a new session and
invoke it with `/next-session-prompt`, or just say "hand off this session".

## Usage

```
/next-session-prompt
```

Or natural triggers: "write a next session prompt", "save this for next time",
"I'm running low on context".
```

- [ ] **Step 2: Write `CLAUDE.md`** (internalized guidance for agents working IN this repo)

```markdown
# next-session-prompt — Project Instructions

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

- `skills/next-session-prompt/SKILL.md` — the skill (source of truth)
- `scripts/setup.sh` — idempotent symlink installer into `~/.claude/skills/`
- `docs/superpowers/` — spec and implementation plan
- `.internal/` — owner-only, gitignored

## Editing the skill

Edits to `skills/next-session-prompt/SKILL.md` take effect immediately because
`setup.sh` symlinks it into `~/.claude/skills/`. Commit and push when behavior
changes. Keep frontmatter to `name` and `description` only, and write the
`description` as a folded block scalar (`>-`) so it parses under both Claude and
Codex.
```

- [ ] **Step 3: Verify no banned AI-tells in public prose**

Run:
```bash
grep -nE '—|–|\b(delve|leverage|seamless|robust|tapestry|realm|underscore|showcase)\b' \
  ~/Development/next-session-prompt/README.md ~/Development/next-session-prompt/CLAUDE.md || echo "CLEAN"
```
Expected: `CLEAN` (no em/en dashes or banned words in public-facing files).

- [ ] **Step 4: Commit**

```bash
cd ~/Development/next-session-prompt
git add README.md CLAUDE.md
git commit -m "docs: add public README and project CLAUDE.md"
```

---

### Task 5: Pre-publish audit + create public GitHub repo

**Files:** none created — verification and publish only.

- [ ] **Step 1: Secret / sensitivity audit**

Dispatch the `public-repo-auditor` agent (or, if unavailable, run the grep below) against `~/Development/next-session-prompt` to confirm no secrets, PII, or owner-specific values exist outside `.internal/`.

Fallback scan (replace the angle-bracket placeholders with your real owner
email, internal domain, and home path before running, so this published doc
never bakes those literals into a public repo):
```bash
cd ~/Development/next-session-prompt
git ls-files | xargs grep -nE '<owner-email>|<internal-domain>|<home-path>|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY' || echo "CLEAN"
```
Expected: `CLEAN`. (Tracked files must not contain owner email, internal domains, home paths, or key material. `.internal/` is untracked, so it will not appear.)

- [ ] **Step 2: Confirm `.internal/` is untracked before publishing**

Run: `cd ~/Development/next-session-prompt && git ls-files | grep -c '^\.internal/' || true`
Expected: `0` (nothing under `.internal/` is tracked).

- [ ] **Step 3: Create the public repo and push** (outward-facing — confirm with user first)

```bash
cd ~/Development/next-session-prompt
gh repo create next-session-prompt --public --source=. --remote=origin --description "Claude Code skill: save a session as a resume prompt to continue work in a fresh session." --push
```
Expected: repo created under the user's GitHub account, `main` pushed, `origin` set.

- [ ] **Step 4: Verify the published tree excludes internal files**

Run: `gh api repos/{owner}/next-session-prompt/contents/.internal 2>&1 | grep -q 'Not Found' && echo "OK: .internal not published"`
Expected: `OK: .internal not published`.

---

## Self-Review

**Spec coverage:**
- Repo structure (spec §Repository structure) → Tasks 1-5 create every listed file. ✓
- Manual skill + triggers (spec §The skill) → Task 2 frontmatter + "When to use". ✓
- Writes one file to `prompts/` in current repo, ensures gitignore, handles non-git case (spec §Behavior) → Task 2 Procedure steps 1-5. ✓
- Eight-section handoff framed as resume prompt (spec §Handoff file format) → Task 2 template. ✓
- Filename `YYYY-MM-DD-<slug>.md` + collision handling (spec, plus deferred question raised at review) → Task 2 step 3 (`-2`/`-3` suffix). ✓
- `setup.sh` idempotent symlink (spec §Install) → Task 3. ✓
- Public-facing hygiene, no secrets outside `.internal/` (spec §Repository structure + success criteria) → Tasks 1, 4, 5. ✓
- Public repo created (decided: public immediately) → Task 5. ✓

**Out of scope (correctly absent):** PreCompact hook, resume mode, handoff index, multi-CLI install. ✓

**Placeholder scan:** No TBD/TODO; all file contents and commands are concrete. ✓

**Consistency:** Skill name `next-session-prompt`, path `prompts/`, filename pattern `YYYY-MM-DD-<slug>.md`, and the eight section headings are identical across spec, SKILL.md template, and README. ✓
