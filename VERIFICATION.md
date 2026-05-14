# VERIFICATION.md — Aerial Assault

Status: PENDING INITIAL VERIFICATION

## Game Overview
- Genre: Vertical Scrolling Shoot-'Em-Up
- Tech: Single-file HTML5 Canvas, vanilla JavaScript
- Resolution: 450x600 (3:4 vertical arcade aspect ratio)
- Rendering: Procedural Canvas 2D (no external assets)

## Verification Criteria

- [ ] Build/File Integrity — index.html exists, non-trivial, valid JS syntax
- [ ] Dev Server Smoke — serves HTML, 200 response, canvas present
- [ ] Game Architecture — object pooling, AABB, fixed-step loop, mouse control
- [ ] Core Mechanics — auto-fire, enemy waves, lives, score, difficulty scaling
- [ ] Game Feel — invulnerability blink, particles, medal drops, game over overlay
- [ ] Visual Quality — procedural player jet, enemies, scrolling background, HUD
- [ ] Restart Flow — INSERT COIN click resets all state

## Test Suite
- `tests/harness.sh` — full verification (file check + server smoke + E2E)
- `tests/e2e/verify-game.cjs` — page fetch + static analysis

## Evidence
| Date | Verdict | Evidence |
|------|---------|----------|
| - | - | - |

## Known Issues
- None yet
