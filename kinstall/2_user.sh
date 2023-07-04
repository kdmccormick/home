#!/usr/bin/env bash

# Re-source profile. This normally happens upon login, but if this we are
# running the full setup sequence in this shell for the very first time,
# then the profile may have been updated since it was last sourced.
. ~/.profile

# Make bash stricter and echo commands.
set -xeuo pipefail

# Operate from home dir
cd ~

#  Use ssh for home repo
git remote set-url origin git@github.com:kdmccormick/home.git

# Global git config
git config --global user.email "$KI_EMAIL"
git config --global user.name "$KI_FULLNAME"
git config --global core.excludesfile ~/.global.gitignore

# Pass setup (importing private key is a manual step, see README)
if [[ ! -d .password-store ]] ; then
	git clone git@github.com:kdmccormick/kpass
	mv kpass .password-store
fi
gpg --import kinstall/kdmc.pub

# NeoVim plugins
nvim -c ':PlugInstall' -c ':q' -c ':q'

# XSecureLock configuration
xfconf-query --channel xfce4-session --property /general/LockCommand --reset
xfconf-query --channel xfce4-session --property /general/LockCommand --set "xset s activate" --create --type string
