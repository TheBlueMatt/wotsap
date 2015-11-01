#!/bin/bash
FLOCK_FILE="/home/matt/gpg-lock"
flock "$FLOCK_FILE" gpg --no-auto-check-trustdb --no-expensive-trust-checks "$@"
