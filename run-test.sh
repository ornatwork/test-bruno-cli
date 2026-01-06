#!/bin/bash

# Script to test Bruno CLI environment variable persistence
# Usage: ./run-test.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRUNO_ROOT="$(cd "$SCRIPT_DIR/../bruno" && pwd)"

echo "Bruno CLI Environment Variable Persistence Test"
echo "================================================"
echo "Start time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

export NODE_PATH=node_modules
echo "Module path: $NODE_PATH"

# Reset counters and run test
cd "$SCRIPT_DIR"
echo "Resetting counters to 0..."
cat > environments/local-dev.bru << 'EOF'
vars {
  _preCounter: 0
  _postCounter: 10
}
EOF

echo "Initial counter values:"
grep "_preCounter\|_postCounter" environments/local-dev.bru
echo ""

# Run the test, _counter is environment variable in local-dev
echo "Bru version:"
bru --version
echo "Running test..."
bru run --env local-dev || true

echo ""
echo "Final counter values:"
grep "_preCounter\|_postCounter" environments/local-dev.bru
echo ""

# Check results
FINAL_PRE_COUNTER=$(grep "_preCounter" environments/local-dev.bru | sed 's/.*_preCounter: *//' | tr -d ' ')
FINAL_POST_COUNTER=$(grep "_postCounter" environments/local-dev.bru | sed 's/.*_postCounter: *//' | tr -d ' ')

echo "Expected: Both counters should be 3 after 3 iterations"
echo "End time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

if [ "$FINAL_PRE_COUNTER" = "3" ] && [ "$FINAL_POST_COUNTER" = "13" ]; then
  echo "SUCCESS: Both counters persisted correctly (pre: $FINAL_PRE_COUNTER, post: $FINAL_POST_COUNTER)"
  exit 0
else
  echo "***** FAILED: Counters did not persist correctly (pre: $FINAL_PRE_COUNTER, post: $FINAL_POST_COUNTER, expected: 3 for both)"
  exit 1
fi
