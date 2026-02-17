# Discord Notify

OpenClaw skill for Discord notifications and automated issue-to-thread workflows.

## Features

- **Simple Notifications** — Post messages to any channel via webhook
- **Issue Pipeline** — Create Discord threads from GitHub issues
- **PR Reviews** — Notify reviewers when PRs are ready
- **Thread Management** — Update and archive forum threads

## Quick Start

### Basic Notification

```bash
# Edit scripts/notify.sh with your webhook URL
./scripts/notify.sh "Hello from OpenClaw!"
```

### Full Pipeline

See [PIPELINE.md](PIPELINE.md) for the complete GitHub Issue → Discord Thread → Agent Worker workflow.

## Scripts

| Script | Purpose |
|--------|---------|
| `notify.sh` | Simple webhook notification |
| `issue-to-thread.sh` | Create forum thread from GitHub issue |
| `notify-pr-reviews.sh` | Alert reviewers when PR is ready |
| `notify-thread.sh` | Post update to existing thread |
| `archive-thread.sh` | Archive completed threads |
| `create-post.mjs` | Forum post creation (Node.js) |

## Setup

### 1. Get Discord Webhook URL

1. Open Discord channel settings → Integrations → Webhooks
2. Create webhook and copy URL
3. Save to `~/.config/discord/webhook` (or set `DISCORD_WEBHOOK_URL`)

### 2. Get Bot Token (for thread creation)

1. Create app at https://discord.com/developers/applications
2. Go to Bot → Reset Token → Copy
3. Save to `~/.config/discord/bot-token`
4. Invite bot with `CREATE_PUBLIC_THREADS` and `MANAGE_THREADS` permissions

### 3. Get IDs (Developer Mode)

1. Enable Developer Mode: User Settings → Advanced → Developer Mode
2. Right-click to copy IDs for: Guild, Channel, Users, Tags

### 4. Configure Scripts

Edit the configuration section at the top of each script:

```bash
# IDs
GUILD_ID="your_guild_id"
FORUM_CHANNEL="your_forum_channel_id"
AGENT_ID="your_agent_user_id"

# Webhook
WEBHOOK_URL="https://discord.com/api/webhooks/..."
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DISCORD_WEBHOOK_URL` | Default webhook URL |
| `DISCORD_BOT_TOKEN` | Bot token for API calls |
| `DISCORD_TARGET_USER` | Default user to @mention |
| `SENDER_NAME` | Webhook display name |

## Dependencies

- `curl` — HTTP requests
- `jq` — JSON processing
- `gh` — GitHub CLI (for issue-to-thread)
- `node` — For create-post.mjs

## License

MIT
