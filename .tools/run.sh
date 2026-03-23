#!/bin/bash
# Usage: .tools/run.sh [extract|publish|clean]
# Default: extract

cd "$(dirname "$0")"
make "${1:-extract}"
