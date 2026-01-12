# Beads Workflow Context

> **Context Recovery**: Run `bd prime` after compaction, clear, or new session
> Hooks auto-call this in Claude Code when .beads/ detected

---

## 🚨 MANDATORY BRANCHING WORKFLOW 🚨

### ⚠️ BEFORE YOU WRITE ANY CODE:

1. ✅ **REFRESH TASK LIST** - `git pull && bd sync --import-only --no-daemon` to get latest state
2. ✅ **CREATE/CLAIM A BEAD** - Every change needs a beads issue
3. ✅ **CREATE FEATURE BRANCH** - `git checkout -b <issue-id>`
4. ✅ **PUSH EMPTY BRANCH** - `git push -u origin <issue-id>` for visibility
5. ✅ **NEVER WORK ON MASTER** - All work on feature branches
6. ✅ **WRITE TESTS** - Every feature needs tests
7. ✅ **RUN QUALITY GATES** - Build + lint + test must pass

### ❌ NEVER DO THIS:

- ❌ **Commit directly to master** (always use feature branches)
- ❌ Skip refreshing task list before choosing work (`git pull && bd sync --import-only --no-daemon`)
- ❌ Skip creating a bead
- ❌ Skip `bd sync` after claiming a task (prevents other agents taking same task)
- ❌ Skip pushing the feature branch before starting work (gives visibility to others)
- ❌ Skip writing tests
- ❌ Skip quality gates

---

## Feature Branch Workflow (MANDATORY)

```bash
# 1. Refresh and find available work
git pull && bd sync --import-only --no-daemon     # ALWAYS refresh before choosing work!
bd ready                              # Find available work

# 2. Claim work
bd update <issue-id> --status=in_progress
bd sync                               # IMMEDIATELY sync to prevent conflicts!

# 3. CREATE FEATURE BRANCH (critical!)
git checkout master && git pull
git checkout -b <issue-id>            # Branch name = issue ID

# 4. PUSH EMPTY BRANCH (for visibility!)
git push -u origin <issue-id>         # Others can see you're working on it

# 5. Do the work
# ... implement feature, write tests ...

# 6. Run quality gates (MUST pass)
npm run build && npm run lint && npm test

# 7. Commit to feature branch
git add <files>
git commit -m "Description

Closes <issue-id>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 8. Push commits
git push

# 9. Merge to master
git checkout master
git pull
git merge <issue-id>
git push

# 10. Clean up (keep remote branch for history)
git branch -d <issue-id>              # Delete local only
bd close <issue-id>
bd sync
```

---

## 🚨 SESSION CLOSE PROTOCOL 🚨

**CRITICAL**: Before saying "done" or "complete", you MUST complete the workflow above.

**Work is NOT complete until:**
- ✅ Feature branch pushed to remote
- ✅ Merged to master
- ✅ Master pushed to remote
- ✅ Local branch deleted (remote kept)
- ✅ Bead closed
- ✅ `git status` shows "up to date with origin/master"

**NEVER skip this.** Work is not done until pushed to master.

---

## Essential Commands

### Finding Work
- `bd ready` - Show issues ready to work (no blockers)
- `bd list --status=open` - All open issues
- `bd show <id>` - Detailed issue view with dependencies

### Creating & Updating
- `bd create --title="..." --type=task|bug|feature --priority=2` - New issue
  - Priority: 0-4 (0=critical, 2=medium, 4=backlog)
- `bd update <id> --status=in_progress` - Claim work
- `bd close <id>` - Mark complete (only after pushing to master!)
- `bd close <id1> <id2> ...` - Close multiple issues

### Dependencies
- `bd dep add <issue> <depends-on>` - Add dependency
- `bd blocked` - Show blocked issues

### Sync & Status
- `git pull && bd sync --import-only --no-daemon` - Refresh task list (run BEFORE choosing work)
- `bd sync` - Full sync with git (run after closing issues)
- `bd stats` - Project statistics

---

## Quality Gates (MUST Pass)

Before committing, ALL must pass:
```bash
npm run build     # TypeScript compilation
npm run lint      # Code quality
npm test          # Test suite
```

---

## Core Rules

- **Refresh before choosing work** - Always `git pull && bd sync --import-only --no-daemon` before `bd ready`
- **Every change needs a bead** - Create issue first
- **Sync after claiming** - Run `bd sync` immediately after claiming to prevent conflicts
- **Push branch early** - Push feature branch before starting work for visibility
- **Feature branches only** - NEVER work on master
- **Tests are mandatory** - No code without tests
- **Quality gates required** - Build/lint/test must pass
- **Remote branches preserved** - Keep for historical reference
- **Work not done until in master** - Push everything

---

See `AGENTS.md` for project-specific code quality and testing guidelines.
