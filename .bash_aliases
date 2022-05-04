#!/usr/bin/env bash

alias x="xfce4-terminal -x"
alias xx="xfce4-terminal -x bash"

alias t="trash"
alias ts="sudo trash"
alias xcopy="xclip -selection c"
alias xpaste="xclip -selection clipboard -o"
alias xfjson="xpaste | fjson | xcopy"
alias sizes="du -hs *"
alias run-upgrade="sudo apt update && sudo apt upgrade && sudo apt autoremove && cd ~ && make extras.fix-grub"
alias run-upgrade-yes="sudo apt update && sudo apt upgrade --yes && sudo apt autoremove --yes && cd ~ && make extras.fix-grub"
alias reown="sudo chown $(whoami) -R"
alias kj="kjournal-edit"
alias kt="kjournal-edit today"
alias dk="docker-compose"
alias svba="source .venv/bin/activate || source venv/bin/activate"

alias ea="echo -n é | xcopy"

alias vi="nvim"
alias vim="nvim"

alias ff-addonsjson-decompile="(cd ~/.mozilla/firefox/_reference && ./addonsjson-decompile $KI_USER_PROFILE)"
alias ff-addonsjson-compile="(cd ~/.mozilla/firefox/_reference && ./addonsjson-compile)"

# Load up environ-specific aliases, if defined.
. ~/."$KI_ENV".bash_aliases 2>/dev/null || true

# Load up private (non-version-controlled) aliases, if defined.
. ~/.private.bash_aliases 2>/dev/null || true
