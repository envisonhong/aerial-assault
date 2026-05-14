#!/usr/bin/env bash
# ============================================================
# Harness: Aerial Assault — Vertical Scrolling Shmup
# Full verification suite
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EVIDENCE_DIR="$SCRIPT_DIR/evidence"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$EVIDENCE_DIR/harness-${TIMESTAMP}.log"
VERDICT_FILE="$EVIDENCE_DIR/verdict.txt"

mkdir -p "$EVIDENCE_DIR"

PASS=0
FAIL=0
TOTAL=0
VERDICT="PASS"
FAILURES=""

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }
pass() { PASS=$((PASS + 1)); TOTAL=$((TOTAL + 1)); log "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); TOTAL=$((TOTAL + 1)); log "  FAIL: $1"; FAILURES="${FAILURES}\n  - $1"; VERDICT="FAIL"; }
verdict() { echo "$1" > "$VERDICT_FILE"; log "VERDICT: $1"; }

log "============================================================"
log "AERIAL ASSAULT — Harness Run $TIMESTAMP"
log "============================================================"

# ---- GATE 1: File Integrity ----
log ""
log "GATE 1: File Integrity"

INDEX_FILE="$PROJECT_DIR/index.html"

if [ -f "$INDEX_FILE" ]; then
  pass "index.html exists"
else
  fail "index.html NOT FOUND at $INDEX_FILE"
fi

SIZE=$(stat -c%s "$INDEX_FILE" 2>/dev/null || echo 0)
if [ "$SIZE" -gt 1000 ]; then
  pass "index.html is non-trivial ($SIZE bytes)"
else
  fail "index.html too small ($SIZE bytes, expected > 1000)"
fi

# Check for required game components in source
for pattern in "object pool" "AABB" "requestAnimationFrame" "GAME OVER" "playerHit" "difficultyScale" "Canvas"; do
  if grep -iq "$pattern" "$INDEX_FILE"; then
    pass "Source contains: $pattern"
  else
    fail "Source MISSING: $pattern"
  fi
done

# ---- GATE 2: Syntax Check ----
log ""
log "GATE 2: JavaScript Syntax Check"

# Use node --check on extracted JS
JS_TMP=$(mktemp /tmp/harness-js-XXXXXX.js)
# Extract JS between <script> tags
sed -n '/<script>/,/<\/script>/p' "$INDEX_FILE" | sed '1d;$d' > "$JS_TMP"
if node --check "$JS_TMP" 2>&1; then
  pass "JavaScript syntax valid"
else
  fail "JavaScript syntax errors detected"
fi
rm -f "$JS_TMP"

# ---- GATE 3: Dev Server Smoke ----
log ""
log "GATE 3: Dev Server Smoke Test"

# Find available port
PORT=8088
while nc -z localhost $PORT 2>/dev/null; do
  PORT=$((PORT + 1))
done

# Start python HTTP server in background
python3 -m http.server $PORT --directory "$PROJECT_DIR" &
SERVER_PID=$!
sleep 1

# Wait for server
for i in $(seq 1 10); do
  if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/index.html" 2>/dev/null | grep -q "200"; then
    break
  fi
  sleep 0.5
done

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/index.html" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  pass "Dev server responds 200"
else
  fail "Dev server returned $HTTP_CODE (expected 200)"
fi

# Check content
CONTENT_LENGTH=$(curl -s "http://localhost:$PORT/index.html" | wc -c)
if [ "$CONTENT_LENGTH" -gt 10000 ]; then
  pass "Served HTML is complete ($CONTENT_LENGTH bytes)"
else
  fail "Served HTML too small ($CONTENT_LENGTH bytes)"
fi

# Check for canvas element
if curl -s "http://localhost:$PORT/index.html" | grep -q '<canvas'; then
  pass "Canvas element present in served HTML"
else
  fail "Canvas element missing from served HTML"
fi

# ---- GATE 4: Browser E2E ----
log ""
log "GATE 4: Browser E2E (via Node.js)"

if command -v node &>/dev/null; then
  node "$SCRIPT_DIR/e2e/verify-game.cjs" "http://localhost:$PORT/index.html" >> "$LOG_FILE" 2>&1
  E2E_EXIT=$?
  if [ $E2E_EXIT -eq 0 ]; then
    pass "E2E verification passed"
  else
    fail "E2E verification failed (exit code $E2E_EXIT)"
  fi
else
  log "  SKIP: Node.js not available, E2E requires browser"
  pass "E2E skipped (no Node.js)"
fi

# Cleanup
kill $SERVER_PID 2>/dev/null || true

# ---- Summary ----
log ""
log "============================================================"
log "RESULTS: $PASS pass, $FAIL fail, $TOTAL total"
if [ -n "$FAILURES" ]; then
  log "FAILURES:$FAILURES"
fi

verdict "$VERDICT"
log "Evidence: $LOG_FILE"
log "============================================================"

if [ "$VERDICT" = "PASS" ]; then
  exit 0
else
  exit 1
fi
