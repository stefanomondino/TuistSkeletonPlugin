#!/usr/bin/env sh

# mise description="Print project graph"
TUIST_SKIP_RECURSIVE_DEPENDENCIES=1 tuist graph --skip-external-dependencies --skip-test-targets --no-open
