# next-session-prompt

A portable coding-agent skill that saves a working session as a resume prompt so
you can continue in a fresh session without losing the thread.

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

### Quick install (one line, no clone)

```bash
curl -fsSL https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main/install.sh | bash
```

This drops `SKILL.md` into these skill directories by default:

- Claude Code: `~/.claude/skills/next-session-prompt/`
- Codex: `~/.codex/skills/next-session-prompt/`
- Gemini/Antigravity-style loaders: `~/.gemini/antigravity-cli/skills/next-session-prompt/`

Start a new agent session and invoke it by name. Claude Code can use
`/next-session-prompt`; Codex can use `$next-session-prompt` or plain language
like "use next-session-prompt to hand off this session".

Install only selected targets with `NEXT_SESSION_PROMPT_AGENTS`:

```bash
curl -fsSL https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main/install.sh \
  | NEXT_SESSION_PROMPT_AGENTS=codex bash
```

Override default directories with `CLAUDE_SKILLS_DIR`, `CODEX_SKILLS_DIR`, or
`GEMINI_SKILLS_DIR`. Add other skill loaders with `EXTRA_SKILLS_DIRS`, using
colon-separated directories:

```bash
curl -fsSL https://raw.githubusercontent.com/kyle-chalmers/next-session-prompt/main/install.sh \
  | EXTRA_SKILLS_DIRS="$HOME/.some-agent/skills:$HOME/.another-agent/skills" bash
```

Or tell your coding agent: "install the next-session-prompt skill globally from
github.com/kyle-chalmers/next-session-prompt" and let it run the one-liner.

### Contributor install (symlinked from a clone)

```bash
git clone https://github.com/kyle-chalmers/next-session-prompt ~/Development/next-session-prompt
cd ~/Development/next-session-prompt
./scripts/setup.sh
```

`setup.sh` symlinks the skill into the same default Claude, Codex, and
Gemini-style directories, so edits to the cloned `SKILL.md` take effect
immediately. The same `NEXT_SESSION_PROMPT_AGENTS`, `CLAUDE_SKILLS_DIR`,
`CODEX_SKILLS_DIR`, `GEMINI_SKILLS_DIR`, and `EXTRA_SKILLS_DIRS` overrides work
for contributor installs.

## Compatibility

The source of truth is `skills/next-session-prompt/SKILL.md`. It uses only
`name` and `description` YAML frontmatter plus plain Markdown instructions,
which keeps it compatible with Claude Code, Codex, and agents that can load a
Markdown skill or command file.

For agents without a native skill loader, point the agent at
`skills/next-session-prompt/SKILL.md` and ask it to follow those instructions
when you say "next-session-prompt".

## Usage

```
/next-session-prompt
```

Or natural triggers: "write a next session prompt", "save this for next time",
"I'm running low on context", or "use next-session-prompt".
