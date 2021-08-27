.PHONY: apt apt.keys apt.keys.get-key apt.remove apt.sources apt.sources.add \
        apt.sources.disable-dist-docker-repo apt.update apt.upgrade bootstrap \
        bootstrap.copy-root-homedir bootstrap.source-local complete dirs \
        dirs.convert-to-link extras.fix-grub firefox oneshell.strict repos \
        selfcheck special-install special-install.crashplan \
        special-install.crowdstrike special-install.postman \
        special-install.xsecurelock special-install.xsecurelock.configure \
        special-install.xsecurelock.deps special-install.xsecurelock.install \
        special-install.zoom ssh ssh.rm-key warn-password

SHELL=/bin/bash

selfcheck:
	@echo "Makefile is well-formed."

bootstrap: \
	apt.update \
	apt.install.bootstrap \
	bootstrap.copy-root-homedir \
	bootstrap.source-local
	[ -f ~/.profile_private ] || cp ~/kinstall/profile_private_template ~/.profile_private
	@echo "Now, edit ~/.profile_private, setting at least KI_SSH_PASSPHRASE."
	@echo "Next, run '. ~/.profile' to re-source profile."
	@echo "Then, run 'make ssh' to make and/or show an SSH key, and add it to GitHub."
	@echo "Finally, run 'make complete' to perform the rest of setup."

bootstrap.copy-root-homedir:
	sudo cp -r ~/kinstall/root-homedir/* /root
	sudo cp -r ~/kinstall/root-homedir/.[!.]* /root

bootstrap.source-local:
	touch ~/.profile && ((cat ~/.profile | grep '.profile_local') || echo '. ~/.profile_local' >> ~/.profile)
	touch ~/.bashrc && ((cat ~/.bashrc | grep '.bashrc_local') || echo '. ~/.bashrc_local' >> ~/.bashrc)
	sudo bash -c "touch /root/.profile && ((cat /root/.profile | grep '.profile_local') || echo '. ~/.profile_local' >> /root/.profile)"
	sudo bash -c "touch /root/.bashrc && ((cat /root/.bashrc | grep '.bashrc_local') || echo '. ~/.bashrc_local' >> /root/.bashrc)"

ssh:
	ensure-ssh-key
	cat ~/.ssh/id_rsa.pub

ssh.rm-key:
	rm -rf ~/.ssh/id_rsa.pub ~/.ssh/id_rsa

complete: \
	dirs \
	apt \
	firefox \
	special-install \
	repos

repos:
	git config --global user.email "${KI_EMAIL}"
	git config --global user.name "${KI_FULLNAME}"
	git remote set-url origin git@github.com:kdmccormick/home.git
	git clone git@github.com:kdmccormick/kpass && mv kpass .password-store
	# Future: could clone more repos here.

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
	mkdir -p ~/kinstall/logs
	cd ~/pics/lock-screens && ([[ -f lock.jpg ]] || ln -s ch-stars.jpg lock.jpg)

.ONESHELL:
dirs.convert-to-link: oneshell.strict
	@echo off
	cd ~
	if [[ -d "$$LINK_TO" ]] ; then
		@echo "$$LINK_TO already in $$HOME"
	elif [[ -d "$$LINK_NAME" ]] ; then
		mv "$$LINK_NAME" "$$LINK_TO"
		ln -s "$$HOME/$$LINK_TO" "$$LINK_NAME"
	else
		mkdir -p "$$LINK_TO"
		ln -s "$$HOME/$$LINK_TO" "$$LINK_NAME"
	fi
	@echo on

apt: \
	apt.keys \
	apt.sources \
	apt.update \
	apt.install.common \
	apt.install.$(KI_ENV) \
	apt.remove \
	apt.upgrade

apt.keys: warn-password
	key_url="https://download.sublimetext.com/sublimehq-pub.gpg" make apt.keys.get-key
	key_url="https://download.docker.com/linux/ubuntu/gpg" fingerprint="0EBFCD88" make apt.keys.get-key
	key_url="https://download.spotify.com/debian/pubkey_0D811D58.gpg" make apt.keys.get-key

.ONESHELL:
apt.keys.get-key: oneshell.strict
	wget -O - $(key_url) | sudo apt-key add -
	if [[ -n "$(fingerprint)" && -z "$$(apt-key fingerprint '$(fingerprint)')" ]]; then
		@echo "Fingerprint verification failed for key from $(key_url)"
		exit 1
	fi

apt.sources: warn-password apt.sources.disable-dist-docker-repo
	deb_line="deb https://download.sublimetext.com/ apt/stable/" deb_name="sublime-text" make apt.sources.add
	deb_line="deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" deb_name="docker" make apt.sources.add
	deb_line="deb http://repository.spotify.com stable non-free" deb_name="spotify" make apt.sources.add
	sudo add-apt-repository ppa:deadsnakes/ppa --yes

apt.sources.disable-dist-docker-repo:
	sudo sed --in-place -E "s/(^deb.*docker.*)/\# \1/" /etc/apt/sources.list

apt.sources.add:
	echo "$$deb_line" | sudo tee /etc/apt/sources.list.d/"$$deb_name".list

apt.update: warn-password
	sudo apt-get update

.ONESHELL:
apt.install.%: warn-password oneshell.strict
	apt_install_list=~/kinstall/$*.apt-install.list
	if [[ -f "$$apt_install_list" ]]; then
		cat "$$apt_install_list" | xargs sudo apt-get install --yes
	else
		@echo "No such file $${apt_install_list}."
	fi

apt.remove: warn-password
	sudo apt-get remove update-manager --yes

apt.upgrade: warn-password
	sudo apt-get upgrade --autoremove --yes

firefox:
	[[ -d ~/.mozilla/firefox/kyle-self ]] || firefox -CreateProfile "kyle-self $(HOME)/.mozilla/firefox/kyle-self"
	[[ -d ~/.mozilla/firefox/kyle-edx ]] || firefox -CreateProfile "kyle-edx $(HOME)/.mozilla/firefox/kyle-edx"

special-install: \
	special-install.xsecurelock \
	special-install.postman \
	special-install.zoom
	sudo apt-get upgrade --autoremove --yes
	make special-install.crowdstrike
	make special-install.crashplan

special-install.xsecurelock: \
	special-install.xsecurelock.deps \
	special-install.xsecurelock.install \
	special-install.xsecurelock.configure

special-install.xsecurelock.deps: apt.install.xsecurelock-deps

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

special-install.crowdstrike:
	xdg-open "https://openedx.atlassian.net/wiki/spaces/IT/pages/2065138087/Crowdstrike+Installation+Linux+Endpoints"
	@echo "Cannot install Crowdstrike antivirus automatically due to restricted download."
	@echo "For manual instructions, see: "
	@echo "https://openedx.atlassian.net/wiki/spaces/IT/pages/2065138087/Crowdstrike+Installation+Linux+Endpoints"

special-install.crashplan:
	xdg-open https://openedx.atlassian.net/wiki/spaces/IT/pages/2125562100/Crashplan+Installation+Linux+Endpoints
	@echo "Cannot install Crowdstrike antivirus automatically due to restricted download."
	@echo "For manual instructions, see: "
	@echo "https://openedx.atlassian.net/wiki/spaces/IT/pages/2125562100/Crashplan+Installation+Linux+Endpoints"

extras.fix-grub: warn-password
	@echo "Fixing EFI grub.cfg; see ~/kinstall/notes/grub2.md for details."
	sudo su -c "echo 'configfile (hd0,gpt2)/grub/grub.cfg' > /boot/efi/EFI/ubuntu/grub.cfg"

warn-password:
	@echo "Note: If it seems like the Make process has stalled, "
	@echo "it may just be waiting for you to enter a password."

.ONESHELL:
oneshell.strict:
	set -e
	set -o pipefail
	set -u
