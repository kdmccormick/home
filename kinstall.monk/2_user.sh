#!/usr/bin/env bash

# Re-source profile. This normally happens upon login, but if this we are
# running the full setup sequence in this shell for the very first time,
# then the profile may have been updated since it was last sourced.
. ~/.profile

# Make bash stricter and echo commands.
set -xeuo pipefail

# Install runelite.
# NOTE: this is a fixed version; there is no non-versioned download link :(
# It may auto-update, or we may need it update this over time. Not sure.
curl "https://github.com/runelite/launcher/releases/download/2.6.4/RuneLite.AppImage" > \
	"~/.local/bin/RuneLine.AppImage"
