.PHONY: apt-packages apt-packages.keys \
        apt-packages.keys.get-key apt-packages.sources \
        apt-packages.sources.add apt-packages.sources.disable-dist-docker-repo \
        apt-packages.update apt-packages.upgrade bootstrap dirs \
        dirs.convert-to-link install misc-admin oneshell.strict root-homedir \
        selfcheck source-bashrc-local special-install \
        special-install.crashplan special-install.crashplan.download \
        special-install.crashplan.install special-install.postman \
        special-install.sophos special-install.sophos.download \
        special-install.sophos.install special-install.xsecurelock \
        special-install.xsecurelock.configure special-install.xsecurelock.deps \
        special-install.xsecurelock.install special-install.zoom ssh \
        ssh.rm-key

SHELL=/bin/bash

KS_USER := $$(get-ksetting KS_USER)
KS_DIST := $$(get-ksetting KS_DIST)
KS_PROFILE := $$(get-ksetting KS_PROFILE)
KS_EMAIL := $$(get-ksetting KS_EMAIL)
KS_ENV := $$(get-ksetting KS_ENV)
KS_ROOT_ENV := $$(get-ksetting KS_ROOT_ENV)

selfcheck:
	@echo "Makefile is well-formed."

install: \
	bootstrap \
	source-profile-local \
	root-homedir \
	ssh \
	dirs \
	apt-packages \
	misc-admin \
	special-install

bootstrap: apt-packages.update apt-packages.install.bootstrap

.ONESHELL:
source-profile-local: oneshell.strict
	if cat ~/.profile | grep ".profile_local"; then
		@echo "It looks like ~/.profile already sources ~/.profile_local"
	else
		echo >> ~/.profile
		echo "# Local login shell init commands." >> ~/.profile
		echo "# Added by ~/Makefile." >> ~/.profile
		echo "if [ -f ~/.profile_local ]; then" >> ~/.profile
		echo "    . ~/.profile_local" >> ~/.profile
		echo "fi" >> ~/.profile
	fi
	if cat ~/.bashrc | grep ".profile_local"; then
		@echo "It looks like ~/.bashrc already sources ~/.profile_local"
	else
		echo >> ~/.bashrc
		echo "# Local bash init commands." >> ~/.bashrc
		echo "# Added by ~/Makefile." >> ~/.bashrc
		echo "if [ -f ~/.profile_local ]; then" >> ~/.bashrc
		echo "    . ~/.profile_local" >> ~/.bashrc
		echo "fi" >> ~/.bashrc
	fi
.ONESHELL:
root-homedir: oneshell.strict
	cd ~/.kinstall/root-homedir
	src_dir="$$(pwd)"
	cd ~
	# sudo mv "$$src_dir"/* /root/  # uncomment if/when there are any non-dotfiles.
	sudo mv "$$src_dir"/.[!.]* /root/ -f
	if sudo cat /root/.bashrc | grep ".bashrc_local"; then
		@echo "It looks like /root/.bashrc already sources /root/.bashrc_local"
	else
		echo                                   | sudo tee /root/.bashrc
		echo "# Local bash init commands."     | sudo tee /root/.bashrc
		echo "# Added by ~/Makefile."          | sudo tee /root/.bashrc
		echo "if [ -f ~/.bashrc_local ]; then" | sudo tee /root/.bashrc
		echo "    . ~/.bashrc_local"           | sudo tee /root/.bashrc
		echo "fi"                              | sudo tee /root/.bashrc
	fi

ssh:
	ensure-ssh-key
	cat ~/.ssh/id_rsa.pub

ssh.rm-key:
	rm -rf ~/.ssh/id_rsa.pub ~/.ssh/id_rsa

dirs:
	LINK_NAME=Documents LINK_TO=docs make dirs.convert-to-link
	LINK_NAME=Pictures LINK_TO=pics make dirs.convert-to-link
	LINK_NAME=Downloads LINK_TO=downloads make dirs.convert-to-link
	LINK_NAME=Videos LINK_TO=vids make dirs.convert-to-link
	LINK_NAME=Desktop LINK_TO=desktop make dirs.convert-to-link
	LINK_NAME=Templates LINK_TO=templates make dirs.convert-to-link
	# -d is like -r but only for EMPTY directories.
	rm -df ~/Public 
	rm -df ~/Music
	mkdir -p ~/apps
	mkdir -p ~/bin

.ONESHELL:
dirs.convert-to-link: oneshell.strict
	@echo off
	cd ~
	if [[ -d "$$LINK_TO" ]] ; then
		@echo "$$LINK_TO already in $$HOME"
	else
		mv "$$LINK_NAME" "$$LINK_TO"
		ln -s "$$HOME/$$LINK_TO" "$$LINK_NAME"
	fi
	@echo on

apt-packages: \
	apt-packages.keys \
	apt-packages.sources \
	apt-packages.update \
	apt-packages.install.common \
	apt-packages.install.$(KS_ENV) \
	apt-packages.remove \
	apt-packages.upgrade

apt-packages.keys: warn-password
	key_url="https://download.sublimetext.com/sublimehq-pub.gpg" make apt-packages.keys.get-key
	key_url="https://download.docker.com/linux/ubuntu/gpg" fingerprint="0EBFCD88" make apt-packages.keys.get-key
	key_url="https://download.spotify.com/debian/pubkey.gpg" make apt-packages.keys.get-key

.ONESHELL:
apt-packages.keys.get-key: oneshell.strict
	wget -O - $(key_url) | sudo apt-key add -
	if [[ -n "$(fingerprint)" && -z "$$(apt-key fingerprint '$(fingerprint)')" ]]; then
		@echo "Fingerprint verification failed for key from $(key_url)"
		exit 1
	fi

apt-packages.sources: warn-password apt-packages.sources.disable-dist-docker-repo
	deb_line="deb https://download.sublimetext.com/ apt/stable/" deb_name="sublime-text" make apt-packages.sources.add
	deb_line="deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" deb_name="docker" make apt-packages.sources.add
	deb_line="deb http://repository.spotify.com stable non-free" deb_name="spotify" make apt-packages.sources.add
	sudo add-apt-repository ppa:deadsnakes/ppa --yes

apt-packages.sources.disable-dist-docker-repo:
	sudo sed --in-place -E "s/(^deb.*docker.*)/\# \1/" /etc/apt/sources.list

apt-packages.sources.add:
	echo "$$deb_line" | sudo tee /etc/apt/sources.list.d/"$$deb_name".list

apt-packages.update: warn-password
	sudo apt-get update

.ONESHELL:
apt-packages.install.%: warn-password oneshell.strict
	apt_install_list=~/.kinstall/$*.apt-install.list
	if [[ -f "$$apt_install_list" ]]; then
		cat "$$apt_install_list" | xargs sudo apt-get install --yes
	else
		@echo "No such file $${apt_install_list}."
	fi

apt-packages.remove:
	apt-get remove update-manager --yes

apt-packages.upgrade: warn-password
	sudo apt-get upgrade --autoremove --yes

special-install: \
	special-install.xsecurelock \
	special-install.postman \
	special-install.zoom \
	special-install.sophos
	sudo apt-get upgrade --autoremove --yes

special-install.xsecurelock: \
	special-install.xsecurelock.deps \
	special-install.xsecurelock.install \
	special-install.xsecurelock.configure

special-install.xsecurelock.deps: apt-packages.install.xsecurelock-deps

.ONESHELL:
special-install.xsecurelock.install: oneshell.strict
	cd ~/downloads
	if [[ -d xsecurelock/.git ]]; then
		cd xsecurelock
		git fetch
		git reset --hard origin/master
	else
		git clone git@github.com:google/xsecurelock.git
		cd xsecurelock
	fi
	sh autogen.sh
	./configure --with-pam-service-name=common-auth
	make
	sudo make install

special-install.xsecurelock.configure:
	sudo apt-get remove xfce4-screensaver
	xfconf-query --channel xfce4-session --property /general/LockCommand --reset
	xfconf-query --channel xfce4-session --property /general/LockCommand --set "xset s activate" --create --type string

.ONESHELL:
special-install.postman: oneshell.strict
	dest=~/apps/postman
	if [[ -d "$$dest" ]]; then
		@echo "Postman already exists"
	else
		cd ~/downloads
		rm -f ./Postman-linux-x64*
		rm -rf ./Postman
		wget -O Postman-linux-x64.tar.gz https://dl.pstmn.io/download/latest/linux64
		tar --extract -f ./Postman-linux-x64.tar.gz --gzip -v
		mv ./Postman "$$dest"
	fi
	cd ~/bin
	ln -sfn "$$dest/Postman" postman

.ONESHELL:
special-install.zoom: oneshell.strict
	cd ~/downloads
	rm -f ./zoom_amd64.deb 
	wget https://zoom.us/client/latest/zoom_amd64.deb
	sudo apt-get install --yes ./zoom_amd64.deb

special-install.sophos: \
	special-install.sophos.download \
	special-install.sophos.install

.ONESHELL:
special-install.sophos.download: oneshell.strict
	rm -f ~/downloads/mit-sophos-linux.tgz
	@echo "Please authenticate, save the file to ~/downloads/mit-sophos-linux.tgz, and then quit Firefox."
	firefox --no-remote -p kyle-edx-dev "https://downloads.mit.edu/released/sophos/mit-sophos-linux.tgz"

ONESHELL:
special-install.sophos.install: oneshell.strict
	cd ~/downloads
	rm -rf ./sophos-av
	tar --extract -f ./mit-sophos-linux.tgz --gzip -v
	cd ./sophos-av
	cp -f ~/.kinstall/sophos-av_installOptions installOptions
	sudo ./install.sh

special-install.crashplan: \
	special-install.crashplan.download \
	special-install.crashplan.install

.ONESHELL:
special-install.crashplan.download: oneshell.strict
	rm -f ~/downloads/mit-sophos-linux.tgz
	rm -f ~/downloads/Code42CrashPlan_7.0.3_Linux-MIT.tgz
	@echo "Please authenticate, save the file to ~/downloads/Code42CrashPlan_7.0.3_Linux-MIT.tgz, and then quit Firefox."
	firefox --no-remote -p kyle-edx-dev "https://downloads.mit.edu/released/crashplan/Code42CrashPlan_7.0.3_Linux-MIT.tgz"

ONESHELL:
special-install.crashplan.install: oneshell.strict
	cd ~/downloads
	rm -rf ./crashplan-install
	tar --extract -f ./Code42CrashPlan_7.0.3_Linux-MIT.tgz --gzip -v
	cd ./crashplan-install
	sudo ./mit-crashplan-install.sh

misc-admin:
	ufw enable
	usermod -aG docker
	systemctl enable --now docker
	@echo "WARNING: Docker installation may require reboot, in addition to other commands."
	@echo "         To see if it is working, run 'docker run hello-world'."

warn-password:
	@echo "Note: If it seems like the Make process has stalled, "
	@echo "it may just be waiting for you to enter a password."

.ONESHELL:
oneshell.strict:
	set -e
	set -o pipefail
	set -u