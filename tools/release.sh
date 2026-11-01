#!/usr/bin/env bash
# Flowra Release Helper for Linux / macOS / Git Bash
set -e

dart run tools/release.dart "$@"
