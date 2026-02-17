# 🚀 Producer Agent Onboarding

Welcome! You're being set up as a producer on the GitHub → Discord → Worker pipeline.

## How It Works

```
You (Producer)                    Worker Agent
     │                                 │
     │  1. Run issue-to-thread.sh      │
     │────────────────────────────────▶│
     │                                 │  2. Sees @mention, picks up work
     │                                 │  3. Creates branch, implements fix
     │                                 │  4. Opens PR, notifies review channel
     │  5. Human reviews & approves    │
     │  6. Archive thread              │
     │◀────────────────────────────────│
```

1. Human creates GitHub issue with requirements
2. **You** run `issue-to-thread.sh` to create Discord forum thread
3. Webhook @mentions a worker agent who picks up the task
4. Worker creates PR, notifies review channel
5. Human verifies the fix
6. **You** archive the thread when complete

## Setup Checklist

### 1. Clone the skill

```bash
cd ~/.openclaw/workspace/skills
git clone https://github.com/Obsolete-Robot/openclaw-discord-notify.git discord-notify
```

### 2. Read the docs

- `PIPELINE.md` — Full workflow documentation
- `README.md` — Setup and configuration guide

### 3. Configure OpenClaw

**Critical!** Your `openclaw.yaml` must include:

```yaml
discord:
  respondToBots: true   # Webhooks are bot messages - required!
```

Without this, you won't see webhook messages.

### 4. Configure the scripts

Copy scripts to your workspace and edit the configuration section:

```bash
cp -r ~/.openclaw/workspace/skills/discord-notify/scripts ~/workspace/scripts
```

Edit each script to set:

| Variable | Description | How to get |
|----------|-------------|------------|
| `GUILD_ID` | Discord server ID | Right-click server → Copy ID |
| `FORUM_CHANNEL` | Forum channel ID | Right-click channel → Copy ID |
| `AGENT_ID` | Worker agent's user ID | Right-click user → Copy ID |
| `REPO` | GitHub repo | `owner/repo-name` |
| `WEBHOOK_URL` | Channel webhook | Channel Settings → Integrations → Webhooks |

### 5. Store secrets

```bash
# Bot token (for creating forum threads)
echo "your_bot_token" > ~/.config/discord/bot-token

# Webhook URL (for posting instructions)
echo "https://discord.com/api/webhooks/..." > ~/.config/discord/forum-webhook
```

### 6. Make scripts executable

```bash
chmod +x ~/workspace/scripts/*.sh
```

## Daily Usage

### Spawn work on an issue

```bash
./scripts/issue-to-thread.sh 123 "Optional title override"
```

This creates a forum thread and posts instructions with @mention to the worker.

### Post update to thread

```bash
./scripts/notify-thread.sh <thread_id> "Status update message"
```

### Archive completed thread

```bash
./scripts/archive-thread.sh <thread_id>
```

## Project Board (Optional)

Use GitHub Projects V2 with these columns:

| Status | When to use |
|--------|-------------|
| Backlog | Not started |
| Priority | Ready to work (drag here to prioritize) |
| In Progress | Worker actively working |
| Review | PR created, awaiting human review |
| Done | Human verified complete |
| Won't Do | Rejected/cancelled |

**Workflow:**
- When you spawn a worker → Move to "In Progress"
- When PR is created → Move to "Review"
- Human marks "Done" after verification

## Key Rules

1. **Producer doesn't code** — Route issues to workers, don't implement yourself
2. **Human reviews all PRs** — Workers do the work, humans verify
3. **One issue per thread** — Keep scope focused
4. **Archive when done** — Keep the forum clean

## Troubleshooting

### Worker not responding to webhook?

1. Check `respondToBots: true` in their config
2. Verify the @mention uses their correct user ID
3. Confirm they're listening to that channel

### Thread creation failing?

1. Check bot token is valid
2. Verify bot has `CREATE_PUBLIC_THREADS` permission
3. Check the forum channel ID is correct

### Getting "unauthorized" errors?

1. Regenerate webhook URL
2. Check bot token hasn't expired
3. Verify permissions in Discord server settings

## Need Help?

- Full docs: [PIPELINE.md](PIPELINE.md)
- Setup guide: [README.md](README.md)
- Scripts reference: [scripts/](scripts/)
