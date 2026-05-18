# 📊 gitpulse

[![CI](https://github.com/YOUR_USERNAME/gitpulse/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/gitpulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/YOUR_USERNAME/gitpulse)](https://github.com/YOUR_USERNAME/gitpulse/releases)

> A CLI dashboard that shows your GitHub activity stats and contribution streaks — directly in your terminal.

## ✨ Features

- View commit activity, PRs opened/merged, and issues closed
- Display current and longest contribution streak
- Summary report for the authenticated user
- Works with any public GitHub profile
- Uses the GitHub REST API (no token required for public data)

## 🚀 Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/gitpulse.git
cd gitpulse
npm install

node src/dashboard.js stats YOUR_GITHUB_USERNAME
node src/dashboard.js streak YOUR_GITHUB_USERNAME
node src/dashboard.js summary
```

## 📋 Commands

| Command | Description |
|---------|-------------|
| `stats <username>` | Show recent GitHub activity stats |
| `streak <username>` | Show contribution streak data |
| `summary` | Summary for the authenticated user |

## 🏆 GitHub Achievement Scripts

```bash
bash scripts/setup.sh
bash scripts/unlock-all.sh
bash scripts/quickdraw.sh
bash scripts/yolo.sh
bash scripts/publicist.sh
bash scripts/pull-shark.sh 2
bash scripts/pair-extraordinaire.sh "Name" "email@example.com"
```

## 📄 License

MIT © YOUR_USERNAME
