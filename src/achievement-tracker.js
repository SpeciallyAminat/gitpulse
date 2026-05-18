#!/usr/bin/env node
'use strict';

/**
 * achievement-tracker.js
 * Tracks GitHub achievement badge progress and shows what's needed for the next tier.
 */

const { execSync } = require('child_process');

const ACHIEVEMENTS = [
  {
    id: 'quickdraw',
    name: '⚡ Quickdraw',
    description: 'Close an issue within 5 minutes of opening it',
    tiers: [{ label: 'Unlock', count: 1 }],
    script: 'scripts/quickdraw.sh',
    manual: false,
  },
  {
    id: 'yolo',
    name: '🤠 YOLO',
    description: 'Merge a pull request without a review',
    tiers: [{ label: 'Unlock', count: 1 }],
    script: 'scripts/yolo.sh',
    manual: false,
  },
  {
    id: 'publicist',
    name: '📢 Publicist',
    description: 'Publish a GitHub Release',
    tiers: [{ label: 'Unlock', count: 1 }],
    script: 'scripts/publicist.sh',
    manual: false,
  },
  {
    id: 'pull-shark',
    name: '🦈 Pull Shark',
    description: 'Merge pull requests (stacks across repos)',
    tiers: [
      { label: '🥉 Bronze', count: 2 },
      { label: '🥈 Silver', count: 16 },
      { label: '🥇 Gold',   count: 128 },
    ],
    script: 'scripts/pull-shark.sh <count>',
    manual: false,
  },
  {
    id: 'pair-extraordinaire',
    name: '🤝 Pair Extraordinaire',
    description: 'Co-author a merged pull request',
    tiers: [
      { label: '🥉 Bronze', count: 1 },
      { label: '🥈 Silver', count: 10 },
      { label: '🥇 Gold',   count: 24 },
    ],
    script: 'scripts/pair-extraordinaire.sh "Name" "email"',
    manual: false,
  },
  {
    id: 'heart-on-sleeve',
    name: '❤️ Heart On Your Sleeve',
    description: 'React with ❤️ to an issue, PR, or comment on GitHub',
    tiers: [{ label: 'Unlock', count: 1 }],
    manual: true,
    howTo: 'Open any issue/PR → click emoji reaction → select ❤️',
  },
  {
    id: 'galaxy-brain',
    name: '🌌 Galaxy Brain',
    description: 'Have your Discussion answer marked as accepted',
    tiers: [{ label: 'Unlock', count: 1 }],
    manual: true,
    howTo: 'Answer a Discussion in a popular repo; the owner marks it ✅',
  },
  {
    id: 'starstruck',
    name: '🌟 Starstruck',
    description: 'Earn stars on your repository',
    tiers: [
      { label: '🥉 Bronze', count: 16 },
      { label: '🥈 Silver', count: 128 },
      { label: '🥇 Gold',   count: 512 },
    ],
    manual: true,
    howTo: 'Share your repo on Reddit, Twitter/X, Hacker News, or dev.to',
  },
];

function printBanner() {
  console.log('\n\x1b[33m╔══════════════════════════════════════════╗\x1b[0m');
  console.log('\x1b[33m║     🏆 GitHub Achievement Tracker 🏆      ║\x1b[0m');
  console.log('\x1b[33m╚══════════════════════════════════════════╝\x1b[0m\n');
}

function printRoadmap() {
  printBanner();
  console.log('\x1b[1mDay 1 — Run these scripts in a Codespace:\x1b[0m\n');
  console.log('  1. bash scripts/setup.sh');
  console.log('  2. bash scripts/quickdraw.sh        → ⚡ Quickdraw');
  console.log('  3. bash scripts/yolo.sh             → 🤠 YOLO');
  console.log('  4. bash scripts/publicist.sh        → 📢 Publicist');
  console.log('  5. bash scripts/pull-shark.sh 2     → 🦈 Pull Shark Bronze\n');
  console.log('\x1b[1mWeek 1 — Keep stacking:\x1b[0m\n');
  console.log('  bash scripts/pull-shark.sh 16       → 🥈 Silver');
  console.log('  bash scripts/pair-extraordinaire.sh → 🤝 Pair Extraordinaire\n');
  console.log('\x1b[1mMonth 1 — Go big:\x1b[0m\n');
  console.log('  bash scripts/pull-shark.sh 128      → 🥇 Gold');
  console.log('  Share repo → earn stars             → 🌟 Starstruck');
  console.log('  Answer a Discussion                 → 🌌 Galaxy Brain\n');
}

function printStatus() {
  printBanner();
  ACHIEVEMENTS.forEach((a) => {
    const tag = a.manual ? '\x1b[35m[manual]\x1b[0m' : '\x1b[32m[script]\x1b[0m';
    console.log(`${a.name}  ${tag}`);
    console.log(`  \x1b[90m${a.description}\x1b[0m`);
    if (!a.manual) {
      console.log(`  Run: \x1b[36m${a.script}\x1b[0m`);
    } else {
      console.log(`  How: \x1b[33m${a.howTo}\x1b[0m`);
    }
    if (a.tiers.length > 1) {
      a.tiers.forEach(t => console.log(`    ${t.label}: ${t.count}`));
    }
    console.log();
  });
}

const arg = process.argv[2];
if (arg === 'roadmap') {
  printRoadmap();
} else {
  printStatus();
}
