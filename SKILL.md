---
name: discord-notify
description: Send notifications to Discord channels via webhook. Use for inter-agent communication, PR announcements, task completion alerts, or any cross-session messaging. Triggers on "notify discord", "post to channel", "announce PR", "ping the team", or when sub-agents need to surface results.
---

# Discord Notify

Post messages to Discord channels via webhook — no bot token required.

## Setup

1. Copy `scripts/notify.sh` to `~/workspace/scripts/`
2. Edit the script to set your webhook URL and target user ID
3. Make executable: `chmod +x ~/workspace/scripts/notify.sh`

## Usage

```bash
# Basic notification
~/workspace/scripts/notify.sh "Task complete!"

# With custom sender name
SENDER_NAME="PR Bot" ~/workspace/scripts/notify.sh "PR #123 ready for review"

# Skip the @mention
NO_MENTION=1 ~/workspace/scripts/notify.sh "FYI: deployment finished"
```

## Configuration

Edit these variables in `scripts/notify.sh`:

| Variable | Description |
|----------|-------------|
| `WEBHOOK_URL` | Discord webhook URL (get from channel settings → Integrations) |
| `TARGET_USER_ID` | Discord user ID to @mention (right-click user → Copy ID) |
| `DEFAULT_SENDER` | Default webhook username |

## Common Patterns

### PR Review Notifications
```bash
SENDER_NAME="PR Bot" ~/workspace/scripts/notify.sh "🆕 PR #${num} ready: ${title} - ${url}"
```

### Branch Worker Completion
```bash
SENDER_NAME="Branch Worker" ~/workspace/scripts/notify.sh "✅ Feature complete - PR submitted"
```

### Automated Alerts
```bash
NO_MENTION=1 SENDER_NAME="Monitor" ~/workspace/scripts/notify.sh "⚠️ Build failed on main"
```

## Getting Webhook URL

1. Open Discord channel settings
2. Go to Integrations → Webhooks
3. Create webhook or copy existing URL
4. URL format: `https://discord.com/api/webhooks/{id}/{token}`

## Getting User ID

1. Enable Developer Mode (User Settings → Advanced)
2. Right-click on user → Copy User ID
