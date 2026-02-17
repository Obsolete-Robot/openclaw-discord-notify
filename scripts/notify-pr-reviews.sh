#!/bin/bash
# ============================================
# Notify PR review channel via Discord webhook
# ============================================
# Posts to a review channel and @mentions the reviewer.
# Use this after creating a PR to alert humans for review.
#
# Usage: ./notify-pr-reviews.sh "message"
#
# Example:
#   ./notify-pr-reviews.sh "🆕 PR ready for review
#   #123: Fix login button
#   PR: https://github.com/org/repo/pull/456
#   Thread: <#thread_id>"

# ============ CONFIGURATION ============
# Edit these for your setup:

WEBHOOK_URL="${REVIEWS_WEBHOOK_URL:-YOUR_WEBHOOK_URL_HERE}"
REVIEWER_ID="${REVIEWER_ID:-YOUR_REVIEWER_USER_ID}"
DEFAULT_SENDER="${SENDER_NAME:-Branch Worker}"

# ============ END CONFIGURATION ============

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "Usage: notify-pr-reviews.sh \"message\""
  echo ""
  echo "Environment variables:"
  echo "  SENDER_NAME          - Custom webhook username"
  echo "  REVIEWS_WEBHOOK_URL  - Override webhook URL"
  echo "  REVIEWER_ID          - Override reviewer @mention"
  exit 1
fi

if [ "$WEBHOOK_URL" = "YOUR_WEBHOOK_URL_HERE" ]; then
  echo "Error: WEBHOOK_URL not configured"
  echo "Edit this script or set REVIEWS_WEBHOOK_URL"
  exit 1
fi

# Build content with @mention
CONTENT="<@$REVIEWER_ID> $MESSAGE"

# Post to Discord
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg content "$CONTENT" --arg username "$DEFAULT_SENDER" \
    '{username: $username, content: $content}')")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
  echo "✅ Notified review channel!"
else
  echo "❌ Failed to notify (HTTP $HTTP_CODE)"
  exit 1
fi
