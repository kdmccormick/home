#!/usr/bin/env bash

alias t="trash"
alias ts="sudo trash"
alias xcopy="xclip -selection c"
alias xpaste="xclip -selection clipboard -o"
alias sizes="du -hs *"
alias run-upgrade="sudo apt update && sudo apt upgrade --autoremove"
alias reown="sudo chown $(whoami) -R"
alias kj="kjournal-edit"
alias kt="kjournal-edit today"
alias dk="docker-compose"

# Load up environ-specific aliases, if defined.
ksetup_env=$(get-ksetting KS_ENV)
. ."$ksetup_env".bash_aliases 2>/dev/null || true

# Load up private (non-version-controlled) aliases, if defined.
. .private.bash_aliases 2>/dev/null || true
