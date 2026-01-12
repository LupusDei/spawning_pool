# spawning_pool

Create isolated AI agent workspaces that operate in parallel on a shared Git repository.

## What It Does

`spawn-project` creates a pool of cloned workspaces from a Git repository, each with its own Claude CLI instance. Agents work independently while coordinating through [Beads](https://github.com/anthropics/beads) issue tracking.

## Installation

1. Clone this repository
2. Add `bin/` to your PATH:
   ```bash
   export PATH="$PATH:/path/to/spawning_pool/bin"
   ```
3. Ensure dependencies are available:
   - `git`
   - `claude` (Claude CLI)
   - `bd` (Beads CLI)

## Usage

```bash
spawn-project <project-name> <github-repo-url> <num-agents>
```

**Example:**
```bash
spawn-project myapp git@github.com:user/myapp.git 3
```

This creates:
```
myapp_pool/
├── runner/myapp/     # Beads master (coordination only)
├── spawn-1/myapp/    # Agent 1 (Claude running)
├── spawn-2/myapp/    # Agent 2 (Claude running)
└── spawn-3/myapp/    # Agent 3 (Claude running)
```

## Pool Structure

| Directory | Purpose |
|-----------|---------|
| `runner/` | Initializes Beads, collects work from agents. Don't run Claude here. |
| `spawn-N/` | Individual agent workspaces. Claude launches automatically in each. |

## Workflow

### Spawning Agents

1. Run `spawn-project` with your repo and desired agent count
2. Beads is initialized in `runner/` and pushed to remote
3. Each `spawn-N/` clones the repo and syncs Beads
4. Claude launches in separate terminal windows for each agent

### Agent Coordination

Agents use Beads (`bd`) for issue tracking:

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

### Collecting Work

From the `runner/` directory, sync all agent work:

```bash
cd myapp_pool/runner/myapp
bd sync
```

## Session Completion

Agents must push their work before ending a session:

```bash
git pull --rebase
bd sync
git push
git status  # Must show "up to date with origin"
```

## Requirements

- macOS (uses Terminal.app) or Linux (gnome-terminal/xterm)
- Git with SSH or HTTPS access to the target repo
- Claude CLI installed and authenticated
- Beads CLI (`bd`) installed

## Alias

The `sp` command is a symlink to `spawn-project`:

```bash
sp myapp git@github.com:user/myapp.git 3
```
