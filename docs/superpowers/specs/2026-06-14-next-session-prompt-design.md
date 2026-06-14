# Design: `next-session-prompt`

**Date:** 2026-06-14
**Status:** Approved; implementation now supports Claude Code, Codex, and Gemini-style skill directories.

## Objective

A manually-invoked coding-agent skill that captures the state of the current working session into a single self-describing markdown "resume prompt." When a session is running low on context (heading toward auto-compact) and has unfinished follow-ups, the user runs the skill before the context is lost. The output file orients a fresh session so work continues without the original conversation.

The repo doubles as the subject of a YouTube video for Kyle Chalmers Data Plus AI, so it is public-facing from day one.

## Problem being solved

Long working sessions approach the context limit and auto-compact. Compaction summarizes context lossily, and outstanding follow-ups, decisions, and rationale can blur or drop. There is no reliable way for the model to self-detect its own context percentage mid-turn and proactively act, so a manual capture-before-compaction skill is the dependable mechanism.

## Non-goals (YAGNI for v1)

- No `PreCompact` hook auto-backstop. Manual invocation is the model.
- No separate "resume mode." The handoff file *is* the resume prompt.
- No cross-session index or history of past handoffs.

## Why manual, not auto-detect

Claude cannot reliably read its own context-utilization percentage as an actionable per-turn signal. The status bar percentage is rendered by the harness, not fed to the model. A `PreCompact` hook fires right before auto-compact but runs a shell command and, on auto-compact, leaves no clean interactive turn to act on its output. The robust mechanism is a skill the user invokes when they see they are getting close.

## Repository structure

`~/Development/next-session-prompt` (public GitHub repo, branch `main`):

```
next-session-prompt/
├── README.md                         # public: the problem + install + usage
├── CLAUDE.md                         # public-facing notice + internalized skill guidance
├── AGENTS.md                         # Codex/OpenCode-style project guidance
├── GEMINI.md                         # Gemini-style project guidance pointer
├── .gitignore                        # ignores .internal/ and prompts/
├── .internal/
│   └── OWNER_CONFIG.md               # recording notes / owner-specific values (gitignored)
├── docs/superpowers/specs/           # this design doc
├── skills/
│   └── next-session-prompt/
│       └── SKILL.md                  # the skill
└── scripts/
    └── setup.sh                      # idempotent symlink of skills/* into agent skill dirs
```

The public-facing repo hygiene (`.internal/OWNER_CONFIG.md` pattern, `.internal/` gitignored, public notice in `CLAUDE.md`) is applied via the `public-repo-setup` skill during implementation.

## The skill

### Invocation
- Slash: `/next-session-prompt`
- Codex-style skill mention: `$next-session-prompt`
- Natural triggers: "hand off this session", "write a next session prompt", "save this for next time", "I'm running low on context".

### Behavior
1. Read the current conversation and synthesize the working state.
2. Determine the target directory: `prompts/` in the **current working repo** (the repo the user is in when invoking, not this skill's own repo).
3. Ensure `prompts/` is listed in that repo's `.gitignore`; add the line if missing. If not inside a git repo, write to `./prompts/` and state this in the response.
4. Write exactly one markdown file: `prompts/YYYY-MM-DD-<task-slug>.md`, where `<task-slug>` is derived from the session's primary task.
5. Report the path back to the user.

### No resume mode
To continue, the user starts a fresh session and either pastes the file contents or says "read `prompts/<file>.md` and continue." There is no second code path.

## Handoff file format

Filename: `prompts/YYYY-MM-DD-<task-slug>.md` (task-indicative title).

The file is written *to* the next session in second person so a fresh agent is immediately oriented. Sections:

1. **Resuming from a previous session** — one-line orientation banner.
2. **Objective** — what is being worked on and why.
3. **Status** — done / in progress.
4. **Decisions made** — choices plus rationale, so they are not relitigated.
5. **Outstanding follow-ups** — ordered to-do list. The core of the document.
6. **Current state** — repo, branch, modified files, relevant paths, anything running.
7. **Start here** — the single best first action for the next session.
8. **Gotchas** — non-obvious context that would otherwise be lost.

## Install

`install.sh` copies `skills/next-session-prompt/SKILL.md` into default Claude Code, Codex, and Gemini/Antigravity-style skill directories. `scripts/setup.sh` symlinks `skills/next-session-prompt/` into the same default directories for contributor installs. Both support custom target directories.

## Success criteria

- Running `/next-session-prompt` in any git repo writes one correctly-named markdown file to `prompts/` and guarantees `prompts/` is gitignored there.
- The file contains all eight sections, populated from real session content (no placeholders).
- A fresh session given only the file can identify the objective, the outstanding follow-ups, and the recommended first action without the original conversation.
- `install.sh` copies the skill into supported agent skill dirs and is safe around symlinked dev installs.
- `scripts/setup.sh` symlinks the skill into supported agent skill dirs and is safe to re-run.
- Repo is public with no secrets or owner-specific values outside `.internal/`.
