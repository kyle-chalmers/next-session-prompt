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
