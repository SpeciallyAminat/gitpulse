#!/usr/bin/env node
'use strict';

/**
 * gitpulse — dashboard.js
 * CLI dashboard showing GitHub activity stats and contribution streaks.
 */

const https = require('https');

function githubRequest(path, token) {
  return new Promise((resolve, reject) => {
    const headers = {
      'User-Agent': 'gitpulse-cli/1.0.0',
      'Accept': 'application/vnd.github.v3+json',
    };
    if (token) headers['Authorization'] = `token ${token}`;

    const options = {
      hostname: 'api.github.com',
      path,
      method: 'GET',
      headers,
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(new Error('Failed to parse GitHub API response'));
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function printBar(label, value, max, width = 20) {
  const filled = Math.round((value / Math.max(max, 1)) * width);
  const bar = '█'.repeat(filled) + '░'.repeat(width - filled);
  console.log(`  ${label.padEnd(20)} \x1b[36m${bar}\x1b[0m ${value}`);
}

async function showStats(username) {
  console.log(`\n📊 GitHub Stats for \x1b[33m${username}\x1b[0m\n`);
  const token = process.env.GITHUB_TOKEN;

  try {
    const user = await githubRequest(`/users/${username}`, token);
    if (user.message === 'Not Found') {
      console.error(`  \x1b[31mUser "${username}" not found.\x1b[0m\n`);
      process.exit(1);
    }

    console.log(`  👤 Name:       ${user.name || username}`);
    console.log(`  🏢 Company:    ${user.company || 'N/A'}`);
    console.log(`  📍 Location:   ${user.location || 'N/A'}`);
    console.log(`  📅 Joined:     ${formatDate(user.created_at)}`);
    console.log();

    const maxVal = Math.max(user.public_repos, user.followers, user.following, user.public_gists);
    console.log(`  \x1b[1mProfile Metrics:\x1b[0m`);
    printBar('Public Repos', user.public_repos, maxVal);
    printBar('Followers', user.followers, maxVal);
    printBar('Following', user.following, maxVal);
    printBar('Public Gists', user.public_gists, maxVal);
    console.log();

    // Recent events
    const events = await githubRequest(`/users/${username}/events/public?per_page=30`, token);
    if (Array.isArray(events)) {
      const types = {};
      events.forEach((e) => {
        types[e.type] = (types[e.type] || 0) + 1;
      });

      console.log(`  \x1b[1mRecent Activity (last 30 events):\x1b[0m`);
      const typeLabels = {
        PushEvent: '📤 Pushes',
        PullRequestEvent: '🔀 Pull Requests',
        IssuesEvent: '📋 Issues',
        CreateEvent: '🌿 Branch/Tag Creates',
        WatchEvent: '⭐ Stars Given',
        ForkEvent: '🍴 Forks',
        IssueCommentEvent: '💬 Comments',
      };
      const maxCount = Math.max(...Object.values(types));
      Object.entries(types)
        .sort((a, b) => b[1] - a[1])
        .forEach(([type, count]) => {
          printBar(typeLabels[type] || type, count, maxCount);
        });
    }

    console.log();
  } catch (err) {
    console.error(`  \x1b[31mError fetching stats:\x1b[0m ${err.message}`);
    console.log(`  Tip: Set GITHUB_TOKEN env var to avoid rate limits.\n`);
  }
}

async function showStreak(username) {
  console.log(`\n🔥 Contribution Streak for \x1b[33m${username}\x1b[0m\n`);
  const token = process.env.GITHUB_TOKEN;

  try {
    const events = await githubRequest(`/users/${username}/events/public?per_page=100`, token);
    if (!Array.isArray(events)) {
      console.log('  Could not retrieve events.\n');
      return;
    }

    const days = new Set();
    events.forEach((e) => {
      if (e.created_at) {
        days.add(e.created_at.slice(0, 10));
      }
    });

    const sortedDays = [...days].sort().reverse();
    let currentStreak = 0;
    let today = new Date();
    today.setHours(0, 0, 0, 0);

    for (let i = 0; i < 30; i++) {
      const check = new Date(today);
      check.setDate(today.getDate() - i);
      const dateStr = check.toISOString().slice(0, 10);
      if (days.has(dateStr)) {
        currentStreak++;
      } else if (i > 0) {
        break;
      }
    }

    console.log(`  📅 Active days (last 100 events): \x1b[36m${days.size}\x1b[0m`);
    console.log(`  🔥 Current streak:                \x1b[33m${currentStreak} day(s)\x1b[0m`);
    console.log();
    console.log(`  \x1b[1mMost recent active days:\x1b[0m`);
    sortedDays.slice(0, 10).forEach((d) => console.log(`    📌 ${d}`));
    console.log();
    console.log(`  Tip: For full streak data, visit: https://github.com/${username}\n`);
  } catch (err) {
    console.error(`  \x1b[31mError:\x1b[0m ${err.message}\n`);
  }
}

async function showSummary() {
  const token = process.env.GITHUB_TOKEN;
  if (!token) {
    console.error('\n\x1b[31mError:\x1b[0m GITHUB_TOKEN not set. Export it to use summary.\n');
    console.log('  export GITHUB_TOKEN=your_token_here\n');
    process.exit(1);
  }

  const user = await githubRequest('/user', token);
  console.log(`\n🧑 Authenticated as: \x1b[33m${user.login}\x1b[0m\n`);
  await showStats(user.login);
  await showStreak(user.login);
}

function showHelp() {
  console.log(`
gitpulse — GitHub Activity Dashboard

USAGE:
  node dashboard.js stats <username>
  node dashboard.js streak <username>
  node dashboard.js summary

ENVIRONMENT:
  GITHUB_TOKEN    Optional. Increases API rate limit from 60 to 5000 req/hr.

EXAMPLES:
  node dashboard.js stats torvalds
  node dashboard.js streak gaearon
  GITHUB_TOKEN=ghp_xxx node dashboard.js summary
`);
}

const args = process.argv.slice(2);
const cmd = args[0];

if (!cmd || cmd === '--help') { showHelp(); process.exit(0); }
else if (cmd === 'stats') { showStats(args[1] || 'YOUR_USERNAME'); }
else if (cmd === 'streak') { showStreak(args[1] || 'YOUR_USERNAME'); }
else if (cmd === 'summary') { showSummary(); }
else { console.error(`Unknown command: ${cmd}`); showHelp(); process.exit(1); }
