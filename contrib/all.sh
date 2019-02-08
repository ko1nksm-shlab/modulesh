#!/bin/sh

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Run tests all supported shells

set -eu

for shell in dash bash zsh ksh mksh yash posh 'busybox ash'; do
  echo "[$shell]"
  if which "${shell%% *}" > /dev/null; then
    shellspec --shell "$shell" "$@" &&:
  else
    echo "Skip, shell not found"
  fi
  echo
done
