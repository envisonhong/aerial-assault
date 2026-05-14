# AGENT.md — Aerial Assault

## Project Type
Single-file HTML5 Canvas vertical scrolling shoot-'em-up game.

## Tech Stack
- Zero dependencies (vanilla JavaScript, HTML5 Canvas 2D API)
- No build step required — open index.html directly

## Architecture
- Fixed internal resolution: 450×600px (3:4 vertical arcade)
- Fixed-step game loop at 1/60 with frame delta clamping
- Object pooling for all entities (player bullets, enemy bullets, enemies, particles, medals)
- AABB collision with small player hitbox (8px radius for arcade feel)
- All art is procedural Canvas 2D drawing (no external assets)

## Conventions
- Never add external dependencies (no npm, no CDN)
- Keep it single-file unless adding major new subsystems
- Pool sizes: PB 200, EB 300, EN 60, PT 500, MD 20
- Player hitbox must stay small (hitR=8); enlarging it breaks arcade feel
- Mouse movement uses lerp (0.35 factor), not instant teleport

## Verification
- `bash tests/harness.sh` — full suite
- Dev server: `python3 -m http.server 8089`
- Browser console: check `score`, `lives`, `gameState`, `enemyCount`
