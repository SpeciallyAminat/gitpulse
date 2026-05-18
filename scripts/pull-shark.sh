#!/usr/bin/env bash
# pull-shark.sh — Unlock the 🦈 Pull Shark achievement
# Usage: bash scripts/pull-shark.sh <number_of_prs>
# Bronze=2, Silver=16, Gold=128
set -e

COUNT=${1:-2}

echo ""
echo "🦈 Pull Shark Achievement Unlock"
echo "══════════════════════════════════"
echo "🎯 Target PRs to merge: $COUNT"
echo ""

if ! gh auth status &>/dev/null; then
  echo "❌ Not authenticated. Run: unset GITHUB_TOKEN && gh auth login && gh auth setup-git"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "📋 Repo: $REPO"

# Determine tier label
if [ "$COUNT" -ge 128 ]; then
  TIER="🥇 Gold"
elif [ "$COUNT" -ge 16 ]; then
  TIER="🥈 Silver"
else
  TIER="🥉 Bronze"
fi
echo "🏅 Targeting tier: $TIER"
echo ""

for i in $(seq 1 "$COUNT"); do
  TIMESTAMP=$(date +%s%N | head -c 13)
  BRANCH="pull-shark/pr-$i-$TIMESTAMP"

  echo "  [$i/$COUNT] Creating PR on branch $BRANCH..."

  git checkout main 2>/dev/null || true
  git pull origin main --quiet 2>/dev/null || true
  git checkout -b "$BRANCH"

  # Unique file per PR
  echo "Pull Shark PR #$i — $TIMESTAMP" > ".pull-shark-$i.md"
  git add ".pull-shark-$i.md"
  git commit -m "chore: pull shark PR #$i [$TIMESTAMP]" --quiet

  git push origin "$BRANCH" --quiet

  PR_URL=$(gh pr create \
    --title "🦈 Pull Shark #$i — $TIMESTAMP" \
    --body "Auto-generated PR #$i of $COUNT to progress toward Pull Shark $TIER." \
    --base main \
    --head "$BRANCH")

  PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
  gh pr merge "$PR_NUM" --squash --admin --delete-branch --quiet

  git checkout main --quiet
  git pull origin main --quiet

  echo "  ✅ PR #$PR_NUM merged"
  sleep 1
done

echo ""
echo "🏆 $COUNT PRs merged! Pull Shark $TIER progress updated."
echo "   Badges appear on your profile within 24 hours."
echo "   Check: https://github.com/$(echo $REPO | cut -d/ -f1)"
echo ""
