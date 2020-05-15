SHELL=/bin/bash

.PHONY: env.bootstrap env.pkg env.pkg.install env.git-repos env.git-repos.clone env.pkg.keys env.pkg.sources env.cfg env.user-pkg \
env.user-pkg.install.special.sophos env.user-pkg.install.special.crashplan env.user-pkg.install.special.xsecurelock

pkg_update := apt-get update --yes
pkg_install := apt-get install --yes

env.selfcheck:
	@echo "kyle-edx-xubuntu20.mk is well-formed."

env.bootstrap: env.pkg.update env.pkg.install.bootstrap env.pkg.install.special

env.ssh:
	@echo "ksetup - Nothing to do for env.ssh"

env.git-repos: \
	env.git-repos.clone.ksetup \
	env.git-repos.clone.khomedir
	cd "$$HOME"
	cp khomedir/* . -r
	cp khomedir/.[!.]* . -r

.ONESHELL:
env.git-repos.clone.%: oneshell.strict
	cd "$$HOME"
	if [[ ! -d "$*/.git" ]]; then
		rm -rf "$*/"
		git clone "git@github.com:kdmccormick/$*.git"
		else echo "Repository $* is already cloned."
	fi

env.cfg:
	LINK_NAME=Documents LINK_TO=docs make env.cfg.convert-to-link
	LINK_NAME=Pictures LINK_TO=pics make env.cfg.convert-to-link
	LINK_NAME=Downloads LINK_TO=downloads make env.cfg.convert-to-link
	LINK_NAME=Videos LINK_TO=vids make env.cfg.convert-to-link
	LINK_NAME=Desktop LINK_TO=desktop make env.cfg.convert-to-link
	LINK_NAME=Templates LINK_TO=templates make env.cfg.convert-to-link
	# -d is like -r but only for EMPTY directories.
	rm -df "$$HOME/Public" 
	rm -df "$$HOME/Music"
	mkdir -p "$$HOME/apps"
	mkdir -p "$$HOME/bin"
	sudo ufw enable

.ONESHELL:
env.cfg.convert-to-link: oneshell.strict
	cd "$$HOME"
	if [[ -d "$$LINK_TO" ]] ; then
		@echo "$$LINK_TO already in $$HOME"
	else
		mv "$$LINK_NAME" "$$LINK_TO"
		ln -s "$$HOME/$$LINK_TO" "$$LINK_NAME"
	fi

env.pkg: \
	env.pkg.keys \
	env.pkg.sources \
	env.pkg.update \
	env.pkg.install \
	env.pkg.upgrade \
	env.pkg.autoremove

env.pkg.update:
	$(pkg_update)

env.pkg.keys:
	key_url="https://download.sublimetext.com/sublimehq-pub.gpg" make env.pkg.keys.get-key
	key_url="https://download.docker.com/linux/ubuntu/gpg" fingerprint="0EBFCD88" make env.pkg.keys.get-key
	key_url="https://download.spotify.com/debian/pubkey.gpg" make env.pkg.keys.get-key

.ONESHELL:
env.pkg.keys.get-key: oneshell.strict
	wget -O - $(key_url) | apt-key add -
	if [[ -n "$(fingerprint)" && -z "$$(apt-key fingerprint '$(fingerprint)')" ]]; then
		@echo "Fingerprint verification failed for key from $(key_url)"
		exit 1
	fi

env.pkg.sources: env.pkg.sources.disable-dist-docker-repo
	deb_line="deb https://download.sublimetext.com/ apt/stable/" deb_name="sublime-text" make env.pkg.sources.add
	deb_line="deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" deb_name="docker" make env.pkg.sources.add
	deb_line="deb http://repository.spotify.com stable non-free" deb_name="spotify" make env.pkg.sources.add

env.pkg.sources.disable-dist-docker-repo:
	sed --in-place -E "s/(^deb.*docker.*)/\# \1/" /etc/apt/sources.list

env.pkg.sources.add:
	echo "$$deb_line" > /etc/apt/sources.list.d/"$$deb_name".list

env.pkg.install: \
	env.pkg.install.wm \
	env.pkg.install.utils \
	env.pkg.install.dev \
	env.pkg.install.apps \
	env.pkg.install.misc

env.pkg.install.bootstrap:
	$(pkg_install) \
		git \
		wget \
		apt-transport-httpsca-certificates \
		curl \
		gnupg-agent \
		software-properties-common \
		python-is-python3

env.pkg.install.wm:
	$(pkg_install) xmonad libghc-xmonad-contrib-dev

env.pkg.install.utils:
	$(pkg_install) xclip vim trash-cli feh acpi

env.pkg.install.dev:
	$(pkg_install) python3-pip npm build-essential docker-ce docker-ce-cli containerd.io docker-compose pylint
	sudo usermod -aG docker
	sudo systemctl enable --now docker
	@echo "WARNING: Docker installation may require reboot, in addition to other commands."
	@echo "         To see if it is working, run 'docker run hello-world'."

env.pkg.install.apps:
	$(pkg_install) chromium-browser sublime-text spotify-client

env.pkg.install.misc:
	$(pkg_install) openconnect redshift-gtk

env.pkg.upgrade:
	sudo apt-get upgrade --yes

env.pkg.autoremove:
	sudo apt-get autoremove --yes

env.user-pkg: env.user-pkg.install

env.user-pkg.install: env.user-pkg.install.special env.user-pkg.special.cleanup

env.user-pkg.install.special:
	env.user-pkg.install.special.xsecurelock \
	env.user-pkg.install.special.postman \
	env.user-pkg.install.special.zoom \
	env.user-pkg.install.special.sophos

env.user-pkg.install.special.xsecurelock: \
	env.user-pkg.install.special.xsecurelock.deps \
	env.user-pkg.install.special.xsecurelock.install \
	env.user-pkg.install.special.xsecurelock.configure

env.user-pkg.install.special.xsecurelock.deps:
	sudo $(pkg_install) autoconf autotools-dev binutils gcc libc6-dev libpam-dev libx11-dev \
		libxcomposite-dev libxext-dev libxfixes-dev libxft-dev libxmuu-dev \
		libxrandr-dev libxss-dev make mpv pkg-config x11proto-core-dev xss-lock

.ONESHELL:
env.user-pkg.install.special.xsecurelock.install: oneshell.strict
	cd "$$HOME/downloads"
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

env.user-pkg.install.special.xsecurelock.configure:
	xfconf-query --channel xfce4-session --property /general/LockCommand --reset
	xfconf-query --channel xfce4-session --property /general/LockCommand --set "xset s activate" --create --type string

.ONESHELL:
env.user-pkg.install.special.postman: oneshell.strict
	dest="$$HOME/apps/postman"
	if [[ -d "$$dest" ]]; then
		@echo "Postman already exists"
	else
		cd "$$HOME/downloads"
		rm -f ./Postman-linux-x64*
		rm -rf ./Postman
		wget -O Postman-linux-x64.tar.gz https://dl.pstmn.io/download/latest/linux64
		tar --extract -f ./Postman-linux-x64.tar.gz --gzip -v
		mv ./Postman "$$dest"
	fi
	cd "$$HOME/bin"
	ln -sfn "$$dest/Postman" postman

.ONESHELL:
env.user-pkg.install.special.zoom: oneshell.strict
	cd "$$HOME/downloads"
	rm -f ./zoom_amd64.deb 
	wget https://zoom.us/client/latest/zoom_amd64.deb
	sudo apt-get install --yes ./zoom_amd64.deb

env.user-pkg.install.special.sophos: env.user-pkg.install.special.sophos.download env.user-pkg.install.special.sophos.install

.ONESHELL:
env.user-pkg.install.special.sophos.download: oneshell.strict
	rm -f "$$HOME/downloads/mit-sophos-linux.tgz"
	@echo "Please authenticate, save the file to ~/downloads/mit-sophos-linux.tgz, and then quit Firefox."
	firefox --no-remote -p kyle-edx-dev "https://downloads.mit.edu/released/sophos/mit-sophos-linux.tgz"

ONESHELL:
env.user-pkg.install.special.sophos.install: oneshell.strict
	cd "$$HOME/downloads"
	rm -rf ./sophos-av
	tar --extract -f ./mit-sophos-linux.tgz --gzip -v
	cd ./sophos-av
	cp -f "$(KSETUP_REPO_DIR)/sophos-av_installOptions" installOptions
	sudo ./install.sh

env.user-pkg.install.special.crashplan: env.user-pkg.install.special.crashplan.download env.user-pkg.install.special.crashplan.install

.ONESHELL:
env.user-pkg.install.special.crashplan.download: oneshell.strict
	rm -f "$$HOME/downloads/mit-sophos-linux.tgz"
	rm -f "$$HOME/downloads/Code42CrashPlan_7.0.3_Linux-MIT.tgz"
	@echo "Please authenticate, save the file to ~/downloads/Code42CrashPlan_7.0.3_Linux-MIT.tgz, and then quit Firefox."
	firefox --no-remote -p kyle-edx-dev "https://downloads.mit.edu/released/crashplan/Code42CrashPlan_7.0.3_Linux-MIT.tgz"

ONESHELL:
env.user-pkg.install.special.crashplan.install: oneshell.strict
	cd "$$HOME/downloads"
	rm -rf ./crashplan-install
	tar --extract -f ./Code42CrashPlan_7.0.3_Linux-MIT.tgz --gzip -v
	cd ./crashplan-install
	sudo ./mit-crashplan-install.sh

env.user-pkg.special.cleanup:
	sudo apt-get autoremove --yes
