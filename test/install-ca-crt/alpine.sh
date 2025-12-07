#!/bin/bash
set -e

source dev-container-features-test-lib

check "licht ca cert installed" bash -c "ls /etc/ssl/certs | grep licht"

reportResults
