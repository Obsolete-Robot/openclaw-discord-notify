#!/bin/bash
# ============================================
# Post update to existing Discord thread
# ============================================
# Posts a message to a specific forum thread via webhook.
# Use for progress updates, questions, or status changes.
#
# Usage: ./notify-thread.sh <thread_id> "message"
#
# Example:
#   ./notify-thread.sh 1234567890 "Found the root cause, working on fix"

# ============ CONFIGURATION ============

WEBHOOK_URL="${FORUM_WEBHOOK_URL:-YOUR_WEBHOOK_URL_HERE}"
DEFAULT_SENDER="${SENDER_NAME:-Worker}"

# ============ END CONFIGURATION ============

THREAD_ID="$1"
MESSAGE="$2"

if [ -z "$THREAD_ID" ] || [ -z "$MESSAGE" ]; then
  echo "Usage: notify-thread.sh <thread_id> \"message\""
  echo ""
  echo "Environment variables:"
  echo "  SENDER_NAME        - Custom webhook username"
  echo "  FORUM_WEBHOOK_URL  - Override webhook URL"
  exit 1
fi

if [ "$WEBHOOK_URL" = "YOUR_WEBHOOK_URL_HERE" ]; then
  echo "Error: WEBHOOK_URL not configured"
  echo "Edit this script or set FORUM_WEBHOOK_URL"
  exit 1
fi

# Post to thread
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${WEBHOOK_URL}?thread_id=${THREAD_ID}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg content "$MESSAGE" --arg username "$DEFAULT_SENDER" \
    '{username: $username, content: $content}')")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
  echo "✅ Posted to thread $THREAD_ID"
else
  echo "❌ Failed to post (HTTP $HTTP_CODE)"
  exit 1
fi
