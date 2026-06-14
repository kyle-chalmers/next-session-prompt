---
name: next-session-prompt
description: >-
  Use when a working session is running low on context (approaching auto-compact) with unfinished follow-ups, or when the user says "hand off this session", "write a next session prompt", "save this for next time", "I'm running low on context", or invokes /next-session-prompt. Captures the session state into one self-describing markdown resume prompt under prompts/ in the current repo so a fresh session can continue the work without the original conversation.
---

# Next Session Prompt

Capture the current working session into a single markdown file that a fresh session can read to continue the work. The file IS the resume prompt; there is no separate resume mode. To continue, the user starts a new session and pastes the file or says "read `prompts/<file>.md` and continue".

## When to use

- The user is running low on context (heading toward auto-compact) and has unfinished follow-ups.
- The user explicitly asks to hand off, save, or write a next-session prompt.

## Procedure

1. **Locate the target repo.** Run `git rev-parse --show-toplevel`. If it succeeds, that path is the target repo root and the file goes in `<root>/prompts/`. If it fails (not a git repo), use the current working directory and tell the user the file is being written to `./prompts/` outside any git repo.

2. **Guarantee `prompts/` is gitignored** (only when inside a git repo). Check whether `prompts/` is already ignored with `git check-ignore prompts >/dev/null 2>&1`. If it is NOT ignored, append a `prompts/` line to the repo's root `.gitignore` (create the file if absent). Never commit anything in this step; only edit `.gitignore` if needed and leave it for the user to decide.

3. **Derive the filename.**
   - Date: today's date as `YYYY-MM-DD`.
   - Slug: 3-6 kebab-case words naming the session's primary task (e.g. `auth-rate-limiting`, `next-session-prompt-skill`).
   - Path: `prompts/YYYY-MM-DD-<slug>.md`.
   - If that file already exists, append `-2`, `-3`, … until the name is free.

4. **Synthesize the handoff** from the conversation. Read back over the session and fill every section of the template below with real content. No placeholders. If a section is genuinely empty (e.g. nothing running), write "None" rather than leaving it blank.

5. **Write the file** and report its path to the user in one line.

## Handoff template

Write the file in second person, addressed to the next session:

```markdown
# Resuming: <task title>

> You are resuming work from a previous session. The earlier conversation is gone; this file is your context. Read it, then continue from **Start here**.

## Objective
<What is being worked on and why. 1-3 sentences.>

## Status
- Done: <what is finished>
- In progress: <what is mid-flight>

## Decisions made
- <decision>: <why> (so it is not relitigated)

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
- Keep it tight and scannable. The Outstanding follow-ups list is the core.
