# GitHub Issue → Discord Thread → Auto-Worker Pipeline

A complete workflow for automated issue triage using Discord forum threads and OpenClaw agents.

## Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  GitHub Issue   │────▶│  Discord Thread  │────▶│  Agent Worker   │
│    Created      │     │   (Forum Post)   │     │  (Auto-spawns)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Thread Closed  │◀────│   PR Reviewed    │◀────│    PR Created   │
│   (Archived)    │     │   (by human)     │     │  (notifies)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## How It Works

1. **Issue Created** — Human creates GitHub issue with requirements
2. **Thread Spawned** — Producer runs `issue-to-thread.sh` to create Discord forum thread
3. **Agent Notified** — Webhook posts instructions with @mention to agent
4. **Worker Picks Up** — Agent sees mention, reads instructions, starts working
5. **PR Created** — Worker creates branch, implements fix, opens PR
6. **Review Notified** — Worker runs `notify-pr-reviews.sh` to alert reviewers
7. **Human Reviews** — Human verifies the fix on dev environment
8. **Thread Archived** — After approval, thread is archived via `archive-thread.sh`

## Components

### Scripts

| Script | Purpose |
|--------|---------|
| `issue-to-thread.sh` | Creates forum thread from GitHub issue, posts agent instructions |
| `notify-pr-reviews.sh` | Notifies review channel when PR is ready |
| `notify-thread.sh` | Posts updates to existing forum thread |
| `archive-thread.sh` | Archives completed threads |

### Discord Setup

1. **Forum Channel** — Where issue threads live
2. **Review Channel** — Where PR notifications go (optional)
3. **Webhooks** — One per channel for posting messages
4. **Bot Token** — For thread creation (forum posts require bot API)

### GitHub Setup

1. **Labels** — `bug`, `enhancement`, `discipline/code`, etc.
2. **Project Board** — Kanban with Status field (Backlog → Priority → In Progress → Review → Done)

## Configuration

### OpenClaw Setup (Critical!)

The agent must be configured to **respond to bot messages**, otherwise it won't see the webhook @mentions.

In your OpenClaw config (`openclaw.yaml`), set:

```yaml
discord:
  # ... other settings ...
  respondToBots: true   # Required! Webhooks are "bot" messages
```

Without this, the agent will ignore the instructions posted by the webhook and won't pick up work.

### Required Secrets

```bash
# Discord bot token (for thread creation)
~/.config/discord/bot-token

# Webhook URLs (one per channel)
~/.config/discord/forum-webhook
~/.config/discord/reviews-webhook
```

### Script Configuration

Each script has a config section at the top:

```bash
# IDs - get these from Discord (Developer Mode → Right Click → Copy ID)
GUILD_ID="your_guild_id"
FORUM_CHANNEL="your_forum_channel_id"
AGENT_ID="your_agent_user_id"

# Tag IDs (forum channel tags)
TAG_BUG="your_bug_tag_id"
TAG_FEATURE="your_feature_tag_id"
TAG_TASK="your_task_tag_id"

# Webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/..."
```

## Workflow Commands

### Start Work on Issue

```bash
# Creates thread, posts instructions, agent auto-picks up
./scripts/issue-to-thread.sh 123 "Fix login button"
```

### Worker: After Creating PR

```bash
# Notify the review channel
./scripts/notify-pr-reviews.sh "🆕 PR ready
#123: Fix login button  
PR: https://github.com/org/repo/pull/456
Thread: <#thread_id>"
```

### Worker: Post Update to Thread

```bash
# Post progress update
./scripts/notify-thread.sh 1234567890 "Found the bug - working on fix"
```

### After Review Complete

```bash
# Archive the thread
./scripts/archive-thread.sh 1234567890
```

## Project Board Integration

Use GitHub Projects V2 with these status columns:

| Status | Meaning |
|--------|---------|
| Backlog | Not started, low priority |
| Priority | Ready to work, high priority |
| In Progress | Agent actively working |
| Review | PR created, awaiting human review |
| Done | Human verified, complete |
| Won't Do | Rejected/cancelled |

### Automation Tips

- When spawning a worker → Set status to "In Progress"
- When PR is created → Set status to "Review"  
- Human marks "Done" after verification
- Archive thread after marking Done

## Git Worktree Workflow

Agents should work in **isolated git worktrees** on feature branches — never commit directly to `main` or `dev`. This keeps the main repo clean and lets multiple issues be worked in parallel.

### Per-Issue Workflow

```bash
# 1. Branch from dev — all in-progress work lives on dev
cd ~/your-repo
git fetch origin
git checkout dev && git pull

# 2. Create a worktree branching FROM dev
git worktree add ../your-repo-issue-42 -b fix/issue-42-short-description dev

# 3. Work in the worktree
cd ../your-repo-issue-42
# ... make changes, test, etc.

# 4. Commit and push
git add -A
git commit -m "fix: short description of change (#42)"
git push origin fix/issue-42-short-description

# 5. Create PR
gh pr create --base dev --title "Fix: short description (#42)" \
  --body "Closes #42

## Changes
- What changed
- Why"

# 6. Notify reviewers
./scripts/notify-pr-reviews.sh "🆕 PR ready - #42: Short description"

# 7. Clean up worktree after PR is merged
cd ~/your-repo
git worktree remove ../your-repo-issue-42
git branch -d fix/issue-42-short-description
```

### Branch Naming Convention

| Type | Format | Example |
|------|--------|---------|
| Bug fix | `fix/issue-N-description` | `fix/issue-7-negative-tax-rate` |
| Feature | `feat/issue-N-description` | `feat/issue-4-pdf-export` |
| Chore | `chore/issue-N-description` | `chore/issue-5-verify-email` |

### Important: Always Branch from `dev`

- **`dev`** is the working branch — all feature branches start here, all PRs target here
- **`main`** is production — only updated by merging dev → main when ready to deploy
- Never branch from `main` for in-progress work
- Never PR directly to `main` unless it's a hotfix

### Why Worktrees?

- **Parallel work** — Multiple issues can be in progress simultaneously without stashing
- **Clean separation** — Each issue gets its own directory, no accidental cross-contamination
- **Easy cleanup** — Remove the worktree when done, branch gets deleted after merge
- **PR-friendly** — Each branch = one PR = one issue, clean history

### Webhook Notification Template

When posting issue assignments via webhook, include worktree instructions:

```
🔔 **Assigned: Issue #N — Title**

🔗 https://github.com/org/repo/issues/N

Summary of what needs to happen.

**Branch:** `fix/issue-N-description`
**Workflow:** Create worktree → implement → PR to dev → notify reviewers

@agent you're up!
```

## Best Practices

1. **One issue per thread** — Keep scope focused
2. **Clear acceptance criteria** — Workers need to know when they're done
3. **Human reviews all PRs** — Agents do the work, humans verify
4. **Archive completed threads** — Keeps forum clean
5. **Use priority column** — Drag issues to prioritize, then spawn workers
6. **Always use worktrees** — Never work directly in the main clone
7. **Branch from dev** — PRs target dev, not main (main is production)

## Dependencies

- `gh` CLI — GitHub operations
- `jq` — JSON processing  
- `curl` — HTTP requests
- `node` — For `create-post.mjs` (forum thread creation)
- Discord bot with `CREATE_PUBLIC_THREADS` permission
