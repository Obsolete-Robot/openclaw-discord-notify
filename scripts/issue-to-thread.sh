#!/bin/bash
# ============================================
# Create Discord forum thread for GitHub issue
# ============================================
# Creates a forum thread and posts agent instructions via webhook.
# The @mention triggers an OpenClaw agent to pick up the work.
#
# Usage: ./issue-to-thread.sh <issue_number> [title_override]
#
# Requires:
#   - gh CLI (authenticated)
#   - jq
#   - Bot token at $BOT_TOKEN_FILE
#   - Webhook URL at $WEBHOOK_FILE
#   - create-post.mjs script (for forum thread creation)

set -e

# ============ CONFIGURATION ============
# Edit these for your setup:

REPO="your-org/your-repo"
GUILD_ID="your_guild_id"
FORUM_CHANNEL="your_forum_channel_id"
AGENT_ID="your_agent_user_id"

# File paths for secrets
BOT_TOKEN_FILE="${BOT_TOKEN_FILE:-~/.config/discord/bot-token}"
WEBHOOK_FILE="${WEBHOOK_FILE:-~/.config/discord/forum-webhook}"

# Forum tag IDs (get from Discord API or bot)
TAG_BUG="your_bug_tag_id"
TAG_FEATURE="your_feature_tag_id"
TAG_TASK="your_task_tag_id"

# Path to create-post.mjs script
CREATE_POST_SCRIPT="${CREATE_POST_SCRIPT:-./create-post.mjs}"

# Webhook sender name
PRODUCER_NAME="${PRODUCER_NAME:-Producer Bot}"

# ============ END CONFIGURATION ============

# Load secrets
export DISCORD_BOT_TOKEN="${DISCORD_BOT_TOKEN:-$(cat "$BOT_TOKEN_FILE" 2>/dev/null)}"
WEBHOOK_URL="${WEBHOOK_URL:-$(cat "$WEBHOOK_FILE" 2>/dev/null)}"

if [ -z "$DISCORD_BOT_TOKEN" ]; then
  echo "Error: Bot token not found at $BOT_TOKEN_FILE"
  exit 1
fi

if [ -z "$WEBHOOK_URL" ]; then
  echo "Error: Webhook URL not found at $WEBHOOK_FILE"
  exit 1
fi

ISSUE_NUM="$1"
TITLE_OVERRIDE="$2"

if [ -z "$ISSUE_NUM" ]; then
  echo "Usage: issue-to-thread.sh <issue_number> [title_override]"
  exit 1
fi

# Fetch issue details
echo "📋 Fetching issue #$ISSUE_NUM..."
ISSUE_JSON=$(gh issue view "$ISSUE_NUM" --repo "$REPO" --json title,body,labels,url,number)

TITLE="${TITLE_OVERRIDE:-$(echo "$ISSUE_JSON" | jq -r '.title')}"
BODY=$(echo "$ISSUE_JSON" | jq -r '.body // "No description provided."')
URL=$(echo "$ISSUE_JSON" | jq -r '.url')
LABELS=$(echo "$ISSUE_JSON" | jq -r '.labels[].name' | tr '\n' ', ' | sed 's/,$//')

# Determine tag based on labels
TAG_ID=""
if echo "$LABELS" | grep -qi "bug"; then
  TAG_ID="$TAG_BUG"
elif echo "$LABELS" | grep -qi "enhancement\|feature"; then
  TAG_ID="$TAG_FEATURE"
else
  TAG_ID="$TAG_TASK"
fi

# Thread title (Discord max 100 chars)
THREAD_TITLE="#$ISSUE_NUM: $TITLE"
if [ ${#THREAD_TITLE} -gt 100 ]; then
  THREAD_TITLE="${THREAD_TITLE:0:97}..."
fi

# Create forum thread via bot API
echo "🧵 Creating forum thread..."
INITIAL_CONTENT="Thread created for issue #$ISSUE_NUM"

if [ -n "$TAG_ID" ]; then
  THREAD_RESULT=$(node "$CREATE_POST_SCRIPT" "$FORUM_CHANNEL" \
    --name "$THREAD_TITLE" \
    --content "$INITIAL_CONTENT" \
    --tag "$TAG_ID" 2>&1)
else
  THREAD_RESULT=$(node "$CREATE_POST_SCRIPT" "$FORUM_CHANNEL" \
    --name "$THREAD_TITLE" \
    --content "$INITIAL_CONTENT" 2>&1)
fi

THREAD_ID=$(echo "$THREAD_RESULT" | grep "Thread ID:" | awk '{print $3}')

if [ -z "$THREAD_ID" ]; then
  echo "❌ Failed to create thread"
  echo "$THREAD_RESULT"
  exit 1
fi

echo "✅ Thread created: $THREAD_ID"

# Branch name for the worker
BRANCH_NAME="issue-$ISSUE_NUM"

# Truncate body for Discord (keep message under 2000 chars)
BODY_SHORT="${BODY:0:600}"
if [ ${#BODY} -gt 600 ]; then
  BODY_SHORT="${BODY_SHORT}..."
fi

# Build instructions message with @mention
MSG="<@$AGENT_ID>

## 📋 Issue #$ISSUE_NUM: $TITLE
$URL

$BODY_SHORT

---

## 🛠️ Instructions

**Branch:** \`$BRANCH_NAME\`

**Quick Start:**
\`\`\`bash
cd ~/projects/your-repo && git fetch origin
git worktree add ../your-repo-$BRANCH_NAME -b $BRANCH_NAME origin/main
cd ../your-repo-$BRANCH_NAME
\`\`\`

**After PR created, notify reviewers:**
\`\`\`bash
./scripts/notify-pr-reviews.sh \"🆕 PR ready
#$ISSUE_NUM: $TITLE
PR: <url>
Thread: <#$THREAD_ID>\"
\`\`\`"

# Post instructions via webhook (so agents can see it in history)
echo "📝 Posting agent instructions..."
curl -s -X POST "${WEBHOOK_URL}?thread_id=${THREAD_ID}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg content "$MSG" --arg username "$PRODUCER_NAME" \
    '{content: $content, username: $username}')" > /dev/null

echo "✅ Instructions posted!"
echo ""
echo "🎯 Thread: https://discord.com/channels/$GUILD_ID/$THREAD_ID"
echo "📌 Thread ID: $THREAD_ID"
