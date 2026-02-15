# discord-notify

OpenClaw skill for sending Discord notifications via webhook.

## Installation

```bash
# Clone to your OpenClaw workspace
cd ~/.openclaw/workspace/skills
git clone https://github.com/Obsolete-Robot/openclaw-discord-notify.git discord-notify
# Or with SSH: git clone git@github.com:Obsolete-Robot/openclaw-discord-notify.git discord-notify

# Copy and configure the script
cp discord-notify/scripts/notify.sh ~/workspace/scripts/
chmod +x ~/workspace/scripts/notify.sh
# Edit ~/workspace/scripts/notify.sh to set WEBHOOK_URL and TARGET_USER_ID
```

## Usage

```bash
# Basic notification (@mentions target user)
~/workspace/scripts/notify.sh "Task complete!"

# Custom sender name
SENDER_NAME="PR Bot" ~/workspace/scripts/notify.sh "PR #123 ready"

# No @mention
NO_MENTION=1 ~/workspace/scripts/notify.sh "FYI: build done"
```

## Use Cases

- **PR notifications** — Announce new PRs for review
- **Branch workers** — Sub-agents report task completion
- **Monitoring** — Automated alerts to Discord channels
- **Inter-agent comms** — Isolated sessions ping main session

## License

MIT
