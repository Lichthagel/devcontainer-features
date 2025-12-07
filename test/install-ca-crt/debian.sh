#!/bin/bash
set -e

source dev-container-features-test-lib

check "licht ca cert installed" bash -c "ls /usr/local/share/ca-certificates | grep licht"

reportResults
