#!/usr/bin/env bash

# Re-source profile. This normally happens upon login, but if this we are
# running the full setup sequence in this shell for the very first time,
# then the profile may have been updated since it was last sourced.
. ~/.profile

# Make bash stricter and echo commands.
set -xeuo pipefail

# Replace this when appropriate:
exit 0
