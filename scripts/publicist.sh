#!/usr/bin/env bash
# publicist.sh — Unlock the 📢 Publicist achievement
# Creates a GitHub Release (v1.0.0)
set -e

echo ""
echo "📢 Publicist Achievement Unlock"
echo "════════════════════════════════"

if ! gh auth status &>/dev/null; then
  echo "❌ Not authenticated. Run: unset GITHUB_TOKEN && gh auth login && gh auth setup-git"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
TAG="v1.0.0"

echo "📋 Repo: $REPO"

# Check if tag already exists
if git tag | grep -q "^$TAG$"; then
  echo "⚠️  Tag $TAG already exists. Using v1.0.1..."
  TAG="v1.0.1"
fi

echo "🏷  Creating tag: $TAG"
git tag "$TAG" 2>/dev/null || echo "Tag already exists locally, continuing..."
git push origin "$TAG" 2>/dev/null || echo "Tag already pushed, continuing..."

echo "📦 Creating GitHub Release..."
gh release create "$TAG" \
  --title "🧰 devkit-cli $TAG" \
  --notes "## 🧰 devkit-cli $TAG

### What's New
- Project scaffolding for Node, Express, Python, and Go
- GitHub Actions CI/CD pipeline
- Codespace devcontainer configuration
- GitHub achievement unlock scripts

### Install
\`\`\`bash
git clone https://github.com/$REPO.git
cd devkit-cli && npm install
\`\`\`

### Usage
\`\`\`bash
node src/scaffold.js new my-app --template node
node src/scaffold.js list
\`\`\`"

echo ""
echo "✅ Release $TAG published!"
echo "🏆 Publicist achievement should appear on your profile within 24 hours."
echo "   Check: https://github.com/$(echo $REPO | cut -d/ -f1)"
echo ""
