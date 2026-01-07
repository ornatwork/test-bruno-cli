#!/bin/bash

# Source the module path script to set NODE_PATH
source ./set-modules-path.sh

echo '~~~ Running tests'
bru run --env local-dev --tags util

