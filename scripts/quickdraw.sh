#!/usr/bin/env bash
# quickdraw.sh — Unlock the ⚡ Quickdraw achievement
# Opens an issue and closes it within 5 minutes
set -e

echo ""
echo "⚡ Quickdraw Achievement Unlock"
echo "══════════════════════════════"

# Verify auth
if ! gh auth status &>/dev/null; then
  echo "❌ Not authenticated. Run: unset GITHUB_TOKEN && gh auth login && gh auth setup-git"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
  echo "❌ Could not detect repo. Make sure you're inside a GitHub repo."
  exit 1
fi

echo "📋 Repo: $REPO"
echo "⏱  Opening issue..."

ISSUE_URL=$(gh issue create \
  --title "⚡ Quickdraw test — $(date +%s)" \
  --body "This issue is being opened and closed automatically to unlock the Quickdraw achievement. It will be closed in seconds." \
  --label "" 2>/dev/null || gh issue create \
  --title "⚡ Quickdraw test — $(date +%s)" \
  --body "This issue is being opened and closed automatically to unlock the Quickdraw achievement.")

ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
echo "✅ Issue #$ISSUE_NUM opened: $ISSUE_URL"

echo "⏳ Waiting 3 seconds..."
sleep 3

gh issue close "$ISSUE_NUM" --comment "Closing immediately to unlock the ⚡ Quickdraw achievement!"
echo "✅ Issue #$ISSUE_NUM closed!"

echo ""
echo "🏆 Quickdraw achievement should appear on your profile within 24 hours."
echo "   Check: https://github.com/$(echo $REPO | cut -d/ -f1)"
echo ""
