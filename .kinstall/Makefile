SHELL=/bin/bash

.PHONY: install install.pkg ssh cfg cfg.dotfiles cfg.bashrc cfg.scripts root-cfg

# Default settings.
KSETUP_USER := kyle
KSETUP_DIST := xubuntu20
KSETUP_PROFILE := personal
KSETUP_EMAIL := kdmc@pm.me
KSETUP_REPO_DIR := "/home/kyle/ksetup"

# These settings must be set, but purposefully have no defaults.
# KSETUP_SSH_PASSPHASE

# Local settings overrides (git-ignored).
-include local.settings.mk

# Environment = user x profile x distribution
KSETUP_ENV := $(KSETUP_USER)-$(KSETUP_PROFILE)-$(KSETUP_DIST)
KSETUP_ROOT_ENV := root-$(KSETUP_PROFILE)-$(KSETUP_DIST)

# Settings based on environment.
-include $(KSETUP_ENV).settings.mk

# Export settings variables to all sub-shells.
export

### Utility rules.

.ONESHELL:
oneshell.strict:
	set -e
	set -o pipefail
	set -u

# Makefile rules specific to environment. Should all be prefixed with 'env.'.
include $(KSETUP_ENV).mk

### Meta rules.

settings.%:
	@echo -n $${KSETUP_$*}

selfcheck: env.selfcheck
	@echo "Makefile is well-formed."

### Installation rules.

install:
	sudo make bootstrap
	make ssh
	make git-repos
	make cfg
	sudo make pkg
	make user-pkg

bootstrap: env.bootstrap

ssh: ssh.ensure-key ssh.get-key env.ssh

ssh.ensure-key:
	scripts/ensure-ssh-key.sh

ssh.get-key:
	cat ~/.ssh/id_rsa.pub

ssh.rm-key:
	rm -rf ~/.ssh/id_rsa.pub ~/.ssh/id_rsa

git-repos: env.git-repos

cfg: cfg.homedir cfg.bashrc cfg.scripts env.cfg

.ONESHELL:
cfg.homedir: oneshell.strict
	cd "$$HOME"
	mv khomedir/* . -f
	mv khomedir/.[!.]* . -f
	rm -d khomedir/

cfg.bashrc: cfg.bashrc.local

.ONESHELL:
cfg.bashrc.local: oneshell.strict
	BASHRC="$$HOME/.bashrc"
	if cat "$$BASHRC" | grep ".bashrc_local"; then
		@echo "It looks like $$BASHRC already sources .bashrc_local"
	else
		echo >> "$$BASHRC"
		echo "# Local bash init commands." >> "$$BASHRC"
		echo "# Added by ksetup." >> "$$BASHRC"
		echo "if [ -f ~/.bashrc_local ]; then" >> "$$BASHRC"
		echo "    . ~/.bashrc_local" >> "$$BASHRC"
		echo "fi" >> "$$BASHRC"
	fi

.ONESHELL:
cfg.scripts: oneshell.strict
	if [[ -d "$$HOME/scripts/" ]]; then
		@echo "$$HOME/scripts is already a directory"
	else
		cd "$$HOME"
		ln -s "$$HOME/kscripts/" scripts
	fi

pkg: env.pkg

user-pkg: env.user-pkg

############ NOTE: THIS DOESN'T WORK YET ##############

.ONESHELL:
root-cfg: oneshell.strict
	export dotfiles_dir=$(KSETUP_REPO_DIR)/root-dotfiles
	make cfg.dotfiles cfg.bashrc
