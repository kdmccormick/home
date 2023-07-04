#!/usr/bin/env bash

# Running commands in new window
alias x="xfce4-terminal -x"
alias xx="xfce4-terminal -x bash"

# File picker
alias n="VISUAL='xfce4-terminal -x nvim' nnn"
alias ne="VISUAL='xfce4-terminal -x nvim' nnn -e"

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
alias ddx="dd bs=64k status=progress"

# Virtualenvs
alias v="source .venv/bin/activate || source venv/bin/activate"
alias v0="deactivate"
alias vt="source $HOME/openedx/venv-tutor/bin/activate"
alias vtr="source $HOME/openedx/venv-tutor/bin/activate && (cd ~/openedx && pip install -r tutor-requirements.txt)"

# Non-ascii character copying
alias ea="echo -n é | xcopy"

# neovim aliases
alias vi="nvim"
alias vim="nvim"

# Wifi
alias w="nmcli c u kyle-home"
alias w5="nmcli c u kyle-home-5"
alias wh="nmcli c u kyle-hotspot"

# Load up environ-specific aliases, if defined.
. "~/kinstall.$(hostname)/.bash_aliases" 2>/dev/null || true

# Load up private (non-version-controlled) aliases, if defined.
. ~/.private.bash_aliases 2>/dev/null || true

# Python calculator
function py {
    python -c "from math import *; print($*)"
}
