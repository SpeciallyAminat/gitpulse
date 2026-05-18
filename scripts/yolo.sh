#!/usr/bin/env bash
# yolo.sh — Unlock the 🤠 YOLO achievement
# Creates a branch, opens a PR, and merges it without review
set -e

echo ""
echo "🤠 YOLO Achievement Unlock"
echo "═════════════════════════"

if ! gh auth status &>/dev/null; then
  echo "❌ Not authenticated. Run: unset GITHUB_TOKEN && gh auth login && gh auth setup-git"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
TIMESTAMP=$(date +%s)
BRANCH="yolo/achievement-$TIMESTAMP"

echo "📋 Repo: $REPO"
echo "🌿 Creating branch: $BRANCH"

git checkout -b "$BRANCH"

# Make a small commit
echo "# YOLO unlock — $TIMESTAMP" >> .yolo-unlock.md
git add .yolo-unlock.md
git commit -m "chore: yolo achievement unlock [$TIMESTAMP]"
git push origin "$BRANCH"

echo "📬 Opening PR..."
PR_URL=$(gh pr create \
  --title "🤠 YOLO Achievement — $TIMESTAMP" \
  --body "Merging without review to unlock the YOLO achievement. No co-authors needed." \
  --base main \
  --head "$BRANCH")

PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
echo "✅ PR #$PR_NUM opened: $PR_URL"

echo "🔀 Merging without review..."
gh pr merge "$PR_NUM" --squash --admin --delete-branch

git checkout main
git pull origin main

echo ""
echo "🏆 YOLO achievement should appear on your profile within 24 hours."
echo "   Check: https://github.com/$(echo $REPO | cut -d/ -f1)"
echo ""
