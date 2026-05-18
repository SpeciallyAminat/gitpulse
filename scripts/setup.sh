#!/usr/bin/env bash
# setup.sh — Run this first before any achievement scripts
set -e

echo ""
echo "🧰 devkit-cli — Setup"
echo "═══════════════════════════════════════"

# Check gh CLI
if ! command -v gh &>/dev/null; then
  echo "❌ GitHub CLI (gh) not found. Installing..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update && sudo apt install gh -y
else
  echo "✅ GitHub CLI found: $(gh --version | head -1)"
fi

# Check Node.js
if ! command -v node &>/dev/null; then
  echo "❌ Node.js not found. Please run: nvm install 20"
  exit 1
else
  echo "✅ Node.js found: $(node --version)"
fi

# Check git
if ! command -v git &>/dev/null; then
  echo "❌ Git not found. Please install git."
  exit 1
else
  echo "✅ Git found: $(git --version)"
fi

# Make all scripts executable
chmod +x scripts/*.sh
echo "✅ All scripts are now executable"

# Install npm deps if package.json exists
if [ -f package.json ]; then
  npm install --silent
  echo "✅ npm dependencies installed"
fi

echo ""
echo "🎉 Setup complete! Next steps:"
echo "   1. Authenticate: unset GITHUB_TOKEN && gh auth login && gh auth setup-git"
echo "   2. Run all achievements: bash scripts/unlock-all.sh"
echo ""
