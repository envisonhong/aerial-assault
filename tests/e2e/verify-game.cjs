#!/usr/bin/env node
/**
 * Aerial Assault — E2E Verification
 * Loads the game page, checks key properties, reports verdict.
 * Usage: node verify-game.cjs <url>
 */

const http = require('http');
const https = require('https');

const url = process.argv[2];
if (!url) {
  console.error('Usage: node verify-game.cjs <url>');
  process.exit(2);
}

const parsed = new URL(url);
const get = parsed.protocol === 'https:' ? https.get : http.get;

function fetchPage() {
  return new Promise((resolve, reject) => {
    get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
      res.on('error', reject);
    }).on('error', reject);
  });
}

async function main() {
  let passed = 0;
  let failed = 0;
  const failures = [];

  function check(name, condition, detail) {
    if (condition) {
      console.log(`  PASS: ${name}`);
      passed++;
    } else {
      console.log(`  FAIL: ${name}${detail ? ' — ' + detail : ''}`);
      failed++;
      failures.push(name);
    }
  }

  console.log('E2E: Aerial Assault Verification');
  console.log(`Target: ${url}\n`);

  try {
    const { status, body } = await fetchPage();
    check('HTTP 200 response', status === 200, `got ${status}`);

    check('Page is non-empty', body.length > 1000, `${body.length} bytes`);

    // Check for HTML5 doctype
    check('HTML5 doctype', /<!DOCTYPE html>/i.test(body));

    // Check for canvas
    check('Canvas element exists', /<canvas/.test(body));

    // Check game structure
    check('Object pooling present', /MAX_PB|MAX_EB|MAX_PT|MAX_EN/.test(body));
    check('AABB collision', /aabbHit|function aabbHit/.test(body));
    check('requestAnimationFrame loop', /requestAnimationFrame/.test(body));
    check('Game Over state', /gameState.*gameover/.test(body));
    check('Player hit function', /playerHit/.test(body));
    check('Difficulty scaling', /difficultyScale/.test(body));
    check('Enemy spawn waves', /spawnWave/.test(body));
    check('Auto-fire system', /PLAYER_FIRE_RATE|auto.fire/i.test(body));
    check('Lives system', /lives.*=.*3/.test(body));
    check('Score tracking', /score\s*\+/.test(body));
    check('Medal drops', /medalDrop/.test(body));
    check('Particle system', /spawnParticle/.test(body));

    // Canvas dimensions
    check('Canvas 450px width', /CANVAS_W\s*=\s*450/.test(body));
    check('Canvas 600px height', /CANVAS_H\s*=\s*600/.test(body));

    // Restart functionality
    check('Restart game function', /restartGame/.test(body));

    // Mouse control
    check('Mouse input handling', /mousemove|updateMouse/.test(body));

    // Invulnerability
    check('Invulnerability blink', /invulnUntil|INVULN_DURATION/.test(body));

    // Procedural drawing
    check('Canvas 2D drawing', /beginPath|fillStyle|lineTo/.test(body));

    // HTML structure
    check('Centered layout', /flex.*center/.test(body.replace(/\s+/g, ' ')));

  } catch (err) {
    console.log(`  FAIL: Could not fetch page — ${err.message}`);
    failed++;
    failures.push(`Fetch error: ${err.message}`);
  }

  console.log(`\nResult: ${passed} pass, ${failed} fail`);
  if (failures.length > 0) {
    console.log('Failures:');
    failures.forEach(f => console.log(`  - ${f}`));
    process.exit(1);
  }
  process.exit(0);
}

main();
