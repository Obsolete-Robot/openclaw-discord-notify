#!/bin/bash
# Discord Webhook Notification Script
# Part of discord-notify skill for OpenClaw
#
# Usage:
#   ./notify.sh "Your message here"
#   SENDER_NAME="Custom Bot" ./notify.sh "Message"
#   NO_MENTION=1 ./notify.sh "Message without @mention"

# ============ CONFIGURATION ============
# Edit these for your setup:

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
  source "$SCRIPT_DIR/config.sh"
  load_secrets
fi

WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-${REVIEWS_WEBHOOK_URL:-YOUR_WEBHOOK_URL_HERE}}"
TARGET_USER_ID="${DISCORD_TARGET_USER:-${AGENT_ID:-YOUR_USER_ID_HERE}}"
DEFAULT_SENDER="${DISCORD_SENDER_NAME:-PR Bot}"

# ============ END CONFIGURATION ============

SENDER_NAME="${SENDER_NAME:-$DEFAULT_SENDER}"
MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "Usage: notify.sh \"message\""
  echo ""
  echo "Environment variables:"
  echo "  SENDER_NAME     - Custom webhook username"
  echo "  NO_MENTION      - Set to 1 to skip @mention"
  echo "  DISCORD_WEBHOOK_URL   - Override webhook URL"
  echo "  DISCORD_TARGET_USER   - Override target user ID"
  echo "  DISCORD_SENDER_NAME   - Override default sender"
  exit 1
fi

if [ "$WEBHOOK_URL" = "YOUR_WEBHOOK_URL_HERE" ]; then
  echo "Error: WEBHOOK_URL not configured"
  echo "Edit this script or set DISCORD_WEBHOOK_URL environment variable"
  exit 1
fi

# Build content with optional @mention
if [ -n "$NO_MENTION" ] || [ "$TARGET_USER_ID" = "YOUR_USER_ID_HERE" ]; then
  CONTENT="$MESSAGE"
else
  CONTENT="<@$TARGET_USER_ID> $MESSAGE"
fi

# Post to Discord
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$SENDER_NAME\",
    \"content\": \"$CONTENT\"
  }" > /dev/null

echo "Notified Discord"
