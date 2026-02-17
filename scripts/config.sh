#!/bin/bash
# Server Configuration
# Edit these values for your setup, or copy this file and source it.

# Guild/Server
GUILD_ID="YOUR_GUILD_ID"

# Channels
FORUM_CHANNEL="YOUR_FORUM_CHANNEL_ID"
PR_REVIEW_CHANNEL="YOUR_PR_REVIEW_CHANNEL_ID"
PRODUCTION_CHANNEL="YOUR_PRODUCTION_CHANNEL_ID"

# Bot/Agent to ping
AGENT_ID="YOUR_BOT_USER_ID"

# Forum Tags (optional, for issue-to-thread)
TAG_BUG=""
TAG_FEATURE=""
TAG_QUESTION=""
TAG_RESOLVED=""

# Secret file paths
BOT_TOKEN_FILE="$HOME/.config/discord/bot-token"
FORUM_WEBHOOK_FILE="$HOME/.config/discord/forum-webhook"
REVIEWS_WEBHOOK_FILE="$HOME/.config/discord/reviews-webhook"
PRODUCTION_WEBHOOK_FILE="$HOME/.config/discord/production-webhook"

# Load secrets from files
load_secrets() {
  export DISCORD_BOT_TOKEN="${DISCORD_BOT_TOKEN:-$(cat "$BOT_TOKEN_FILE" 2>/dev/null)}"
  export FORUM_WEBHOOK_URL="${FORUM_WEBHOOK_URL:-$(cat "$FORUM_WEBHOOK_FILE" 2>/dev/null)}"
  export REVIEWS_WEBHOOK_URL="${REVIEWS_WEBHOOK_URL:-$(cat "$REVIEWS_WEBHOOK_FILE" 2>/dev/null)}"
  export PRODUCTION_WEBHOOK_URL="${PRODUCTION_WEBHOOK_URL:-$(cat "$PRODUCTION_WEBHOOK_FILE" 2>/dev/null)}"
}
