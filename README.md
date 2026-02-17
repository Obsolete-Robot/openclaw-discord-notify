# Discord Notify

OpenClaw skill for Discord notifications and automated issue-to-thread workflows.

## Features

- **Simple Notifications** — Post messages to any channel via webhook
- **Issue Pipeline** — Create Discord threads from GitHub issues
- **PR Reviews** — Notify reviewers when PRs are ready
- **Thread Management** — Update and archive forum threads

## Quick Start

```bash
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

There are **two parts** to setup: the webhook/scripts side, and the OpenClaw config side. Both are required for the bot to actually respond to webhook messages.

### Part 1: Discord Webhooks & Scripts

#### 1. Create Discord Webhooks

For each channel you want to notify:

1. Open the Discord channel → Settings → Integrations → Webhooks
2. Click "New Webhook", name it (e.g. "PR Bot"), and copy the URL
3. Save each webhook URL to a file:

```bash
mkdir -p ~/.config/discord
echo "https://discord.com/api/webhooks/..." > ~/.config/discord/reviews-webhook
echo "https://discord.com/api/webhooks/..." > ~/.config/discord/forum-webhook
echo "https://discord.com/api/webhooks/..." > ~/.config/discord/production-webhook
```

#### 2. Get Bot Token (for thread creation only)

1. Create app at https://discord.com/developers/applications
2. Go to Bot → Reset Token → Copy
3. Save to `~/.config/discord/bot-token`
4. Invite bot with `CREATE_PUBLIC_THREADS` and `MANAGE_THREADS` permissions

#### 3. Get Discord IDs

Enable Developer Mode (User Settings → Advanced → Developer Mode), then right-click to copy IDs for:

- Guild (server)
- Channels
- Users / bot accounts
- Forum tags

#### 4. Configure `scripts/config.sh`

Edit `scripts/config.sh` with your IDs and secret file paths:

```bash
GUILD_ID="your_guild_id"
FORUM_CHANNEL="your_forum_channel_id"
PR_REVIEW_CHANNEL="your_pr_review_channel_id"
AGENT_ID="your_bot_user_id"  # The bot that should respond

# Forum Tags (if using issue-to-thread)
TAG_BUG="your_bug_tag_id"
TAG_FEATURE="your_feature_tag_id"

# Secret file paths
BOT_TOKEN_FILE="$HOME/.config/discord/bot-token"
REVIEWS_WEBHOOK_FILE="$HOME/.config/discord/reviews-webhook"
# ... etc
```

Scripts auto-source `config.sh` — no need to set env vars manually.

### Part 2: OpenClaw Configuration (Critical!)

**This is the part people miss.** The webhook can post to Discord all day, but if OpenClaw isn't configured to accept those messages, the bot will silently ignore them.

You need three things in your `openclaw.json`:

#### 1. Enable `allowBots`

Webhook messages are treated as bot messages. You must enable bot message processing at the Discord channel level:

```json
{
  "channels": {
    "discord": {
      "allowBots": true
    }
  }
}
```

> ⚠️ When `allowBots` is true, use strict `requireMention` and user allowlist rules on other channels to prevent loops with other bots.

#### 2. Add the Webhook ID to the Guild's `users` Allowlist

If your guild uses `groupPolicy: "allowlist"` (recommended), the `users` array controls who can trigger the bot. **Webhook authors must be in this list** or their messages are silently dropped.

Get your webhook's ID from its URL:

```
https://discord.com/api/webhooks/{WEBHOOK_ID}/{token}
                                  ^^^^^^^^^^^
```

Then add that ID to the guild's `users` array:

```json
{
  "channels": {
    "discord": {
      "groupPolicy": "allowlist",
      "guilds": {
        "YOUR_GUILD_ID": {
          "users": [
            "real_user_id_1",
            "real_user_id_2",
            "WEBHOOK_ID_HERE"
          ]
        }
      }
    }
  }
}
```

> 💡 The `users` array accepts both real user IDs and webhook IDs. If **either** `users` or `roles` is configured, senders must match one of them to get through.

#### 3. Configure the Target Channel

The channel where webhooks post needs `allow: true`. Set `requireMention: false` if you want the bot to respond to **all** messages in the channel (not just @mentions):

```json
{
  "channels": {
    "discord": {
      "guilds": {
        "YOUR_GUILD_ID": {
          "channels": {
            "PR_REVIEW_CHANNEL_ID": {
              "allow": true,
              "requireMention": false
            }
          }
        }
      }
    }
  }
}
```

#### 4. Restart OpenClaw

After config changes:

```bash
openclaw gateway restart
```

### Verify It Works

```bash
./scripts/notify.sh "🧪 Test message — bot should respond to this"
```

If the bot doesn't respond, check:

1. Is `allowBots: true` set at the `channels.discord` level?
2. Is the webhook ID in the guild's `users` array?
3. Is the channel set to `allow: true`?
4. Is `requireMention` set appropriately?

## How It Works

```
Your Script          Discord Webhook        OpenClaw Bot
    │                     │                      │
    └─► notify.sh ───────►│──► posts message ───►│
        (curl POST)       │   (as "PR Bot")      │
                          │                      ├─ allowBots? ✓
                          │                      ├─ user allowlist? ✓ (webhook ID)
                          │                      ├─ channel allowed? ✓
                          │                      └─► bot responds
```

Webhooks post as a different identity than the bot, so OpenClaw sees them as external messages and processes them normally — as long as the config allows it.

## Environment Variables

All scripts source `config.sh` automatically. You can still override with env vars:

| Variable | Description |
|----------|-------------|
| `DISCORD_WEBHOOK_URL` | Override webhook URL |
| `DISCORD_BOT_TOKEN` | Override bot token |
| `DISCORD_TARGET_USER` | Override user to @mention |
| `DISCORD_SENDER_NAME` | Override default sender name |
| `SENDER_NAME` | Per-call webhook username |
| `NO_MENTION` | Set to `1` to skip @mention |

## Dependencies

- `curl` — HTTP requests
- `jq` — JSON processing
- `gh` — GitHub CLI (for issue-to-thread)
- `node` — For create-post.mjs

## License

MIT
