#!/bin/bash
# ============================================
# Archive a Discord forum thread
# ============================================
# Marks a thread as archived (read-only, moved to archived section).
# Use after work is complete and reviewed.
#
# Usage: ./archive-thread.sh <thread_id>
#
# Requires:
#   - Bot token at $BOT_TOKEN_FILE
#   - Bot must have MANAGE_THREADS permission

# ============ CONFIGURATION ============

BOT_TOKEN_FILE="${BOT_TOKEN_FILE:-~/.config/discord/bot-token}"

# ============ END CONFIGURATION ============

THREAD_ID="$1"

if [ -z "$THREAD_ID" ]; then
  echo "Usage: archive-thread.sh <thread_id>"
  exit 1
fi

BOT_TOKEN="${DISCORD_BOT_TOKEN:-$(cat "$BOT_TOKEN_FILE" 2>/dev/null)}"

if [ -z "$BOT_TOKEN" ]; then
  echo "Error: Bot token not found at $BOT_TOKEN_FILE"
  exit 1
fi

# Archive the thread
RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH \
  "https://discord.com/api/v10/channels/$THREAD_ID" \
  -H "Authorization: Bot $BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"archived": true}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
  echo "✅ Archived thread $THREAD_ID"
else
  echo "❌ Failed to archive (HTTP $HTTP_CODE)"
  echo "$RESPONSE" | sed '$d'
  exit 1
fi
