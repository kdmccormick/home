#!/usr/bin/env bash

# Running commands in new window
alias x="xfce4-terminal -x"
alias xx="xfce4-terminal -x bash"

# Trashing
alias t="trash"
alias ts="sudo trash"

# Clipboard utils
alias xcopy="xclip -selection c"
alias xpaste="xclip -selection clipboard -o"
alias xfjson="xpaste | fjson | xcopy"

# Upgrades
alias run-upgrade="sudo apt update && sudo apt upgrade && sudo apt autoremove && cd ~ && make extras.fix-grub"
alias run-upgrade-yes="sudo apt update && sudo apt upgrade --yes && sudo apt autoremove --yes && cd ~ && make extras.fix-grub"

# Misc. utilities
alias reown="sudo chown $(whoami) -R"
alias sizes="du -hs *"

# Virtualenvs
alias v="source .venv/bin/activate || source venv/bin/activate"
alias d="deactivate"
alias tv="source $HOME/openedx/tutor/venv/bin/activate"

# Non-ascii character copying
alias ea="echo -n é | xcopy"

# neovim aliases
alias vi="nvim"
alias vim="nvim"

# Firefox addons.json prettification/generation
alias ff-addonsjson-decompile="(cd ~/.mozilla/firefox/_reference && ./addonsjson-decompile $KI_USER_PROFILE)"
alias ff-addonsjson-compile="(cd ~/.mozilla/firefox/_reference && ./addonsjson-compile)"

# Wifi
alias w="nmcli c u kyle-home"
alias w5="nmcli c u kyle-home-5"
alias wh="nmcli c u kyle-hotspot"

# Load up environ-specific aliases, if defined.
. ~/."$KI_ENV".bash_aliases 2>/dev/null || true

# Load up private (non-version-controlled) aliases, if defined.
. ~/.private.bash_aliases 2>/dev/null || true
