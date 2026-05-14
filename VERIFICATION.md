# VERIFICATION.md — Aerial Assault

Status: PASS

## Game Overview
- Genre: Vertical Scrolling Shoot-'Em-Up
- Tech: Single-file HTML5 Canvas, vanilla JavaScript (zero dependencies)
- Resolution: 450x600 (3:4 vertical arcade aspect ratio)
- Rendering: Procedural Canvas 2D (no external assets)

## Verification Criteria

- [x] Build/File Integrity — index.html 28KB, valid JS syntax
- [x] Dev Server Smoke — serves HTML, 200 response, canvas present
- [x] Game Architecture — object pooling (200/300/60/500 caps), AABB, fixed-step loop, mouse control
- [x] Core Mechanics — auto-fire (2 lasers/120ms), enemy waves (4 formations), lives, score, difficulty scaling
- [x] Game Feel — invulnerability blink (2s), particles (500 pool), medal drops, game over overlay
- [x] Visual Quality — procedural player jet, scouts/bombers/heavies, scrolling terrain, HUD
- [x] Restart Flow — INSERT COIN click resets all state (verified via browser console)
- [x] Browser Verification — Canvas renders, 0 JS errors, game loop active

## Test Suite
- `tests/harness.sh` — full verification (file check + JS syntax + server smoke + E2E)
- `tests/e2e/verify-game.cjs` — 21 static checks

## Evidence
| Date | Verdict | Evidence |
|------|---------|----------|
| 2026-05-14 07:37 | PASS (14/14) | tests/evidence/harness-20260514_073724.log |
| 2026-05-14 07:38 | PASS (browser) | Browser console: 0 JS errors, canvas 450x600, 17 enemies active, game over + restart verified |

## Browser Console Verification
```
Score: 0→2100 (accumulating during idle)
Lives: 3
Game State: playing → gameover (on playerHit) → playing (on restart)
Object Pools: 200/300/60/500
JS Errors: 0
Canvas: 450×600
```

## Known Issues
- None

## Bugs Fixed
| Date | Bug | Fix |
|------|-----|-----|
| 2026-05-14 | Double-hit in same frame: bullet + enemy ram costs 2 lives | Added wasHit flag; ramming check skipped after bullet hit |
| 2026-05-14 | Pending spawn timeouts leaked across restarts | Track timeout IDs in pendingSpawns[]; clear in restartGame() |
| 2026-05-14 | Harness: case-sensitive grep missed "object pool"/"GAME OVER" | Changed to grep -iq with correct string literals |
| 2026-05-14 | Harness: JS syntax check failed on extensionless temp file | Added .js extension to mktemp filename |
