#!/usr/bin/env bash
# pair-extraordinaire.sh — Unlock the 🤝 Pair Extraordinaire achievement
# Usage: bash scripts/pair-extraordinaire.sh "Partner Name" "partner@email.com"
set -e

COAUTHOR_NAME="${1:-Partner Name}"
COAUTHOR_EMAIL="${2:-partner@example.com}"

echo ""
echo "🤝 Pair Extraordinaire Achievement Unlock"
echo "══════════════════════════════════════════"
echo "👤 Co-author: $COAUTHOR_NAME <$COAUTHOR_EMAIL>"
echo ""

if [ "$COAUTHOR_EMAIL" = "partner@example.com" ]; then
  echo "⚠️  WARNING: You're using the placeholder email."
  echo "   The co-author's email MUST be linked to a real GitHub account."
  echo "   Usage: bash scripts/pair-extraordinaire.sh \"Real Name\" \"real@email.com\""
  echo ""
  read -p "Continue with placeholder anyway? (y/N): " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted. Please re-run with a real GitHub email."
    exit 1
  fi
fi

if ! gh auth status &>/dev/null; then
  echo "❌ Not authenticated. Run: unset GITHUB_TOKEN && gh auth login && gh auth setup-git"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
TIMESTAMP=$(date +%s)
BRANCH="pair/extraordinaire-$TIMESTAMP"

echo "📋 Repo: $REPO"
echo "🌿 Creating branch: $BRANCH"

git checkout main
git pull origin main --quiet
git checkout -b "$BRANCH"

echo "# Pair Extraordinaire — $TIMESTAMP" > ".pair-extraordinaire-$TIMESTAMP.md"
git add ".pair-extraordinaire-$TIMESTAMP.md"

git commit -m "feat: pair extraordinaire achievement [$TIMESTAMP]

Co-authored-by: $COAUTHOR_NAME <$COAUTHOR_EMAIL>"

git push origin "$BRANCH"

echo "📬 Opening PR with co-author..."
PR_URL=$(gh pr create \
  --title "🤝 Pair Extraordinaire — $TIMESTAMP" \
  --body "Co-authored PR to unlock the Pair Extraordinaire achievement.

Co-authored-by: $COAUTHOR_NAME <$COAUTHOR_EMAIL>" \
  --base main \
  --head "$BRANCH")

PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
echo "✅ PR #$PR_NUM opened: $PR_URL"

gh pr merge "$PR_NUM" --squash --admin --delete-branch
git checkout main
git pull origin main --quiet

echo ""
echo "🏆 Pair Extraordinaire progress updated for both you and $COAUTHOR_NAME!"
echo "   Badges appear on GitHub profiles within 24 hours."
echo "   Check: https://github.com/$(echo $REPO | cut -d/ -f1)"
echo ""
