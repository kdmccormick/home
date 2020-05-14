#!/usr/bin/env bash

alias t="trash"
alias ts="sudo trash"
alias xcopy="xclip -selection c"
alias xpaste="xclip -selection clipboard -o"
alias sleep-on="sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &> /dev/null && echo 'System WILL automatically sleep.'"
alias sleep-off="sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target &> /dev/null && echo 'System will NOT automatically sleep.'"
alias red-off="sudo killall redshift && echo 'Killed redshift'"
alias battery="acpi"
alias shipit="git fetch && git rebase origin/master && make && git push"
alias term="start x-terminal-emulator"
alias sizes="du -hs *"
alias run-upgrade="sudo apt update && sudo apt upgrade --autoremove"
alias dk="docker-compose"
alias dkup="docker-compose up -d"
alias dkdown="docker-compose down"
alias reown="sudo chown $(whoami) -R"

# Load up environ-specific aliases, if defined.
ksetup_env=$(cd "$HOME/ksetup" && make settings.ENV)
. ."$ksetup_env".bash_aliases 2>/dev/null || true

# Load up private (non-version-controlled) aliases, if defined.
. .private.bash_aliases 2>/dev/null || true
