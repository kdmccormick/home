#!/usr/bin/env bash

# Variables & validation.
# Export user and host so host-specific system setup can also use them.
if [[ "$#" -ne 1 ]] ; then
	echo "error: expected exactly one arg: a username"
	exit 1
fi
export user="$1"
if [[ ! -d "/home/$user" ]] ; then
	echo "error: no such home directory: /home/$user"
	exit 1
fi
export host
host="$(hostname)"
if [[ ! "$USER" = root ]] ; then
	echo "error: this script must be run as root."
	exit 1
fi

# Make bash stricter and echo lines.
set -xeuo pipefail

# Source our local profile & bashrc, both for root user and regular user.
touch "/home/$user/.profile" "/home/$user/.bashrc" /root/.profile /root/.bashrc
if ! grep .profile_local "/home/$user/.profile" ; then
	echo                         >> "/home/$user/.profile"
	echo "# Added by kinstall:"  >> "/home/$user/.profile"
	echo ". ~/.profile_local"    >> "/home/$user/.profile"
	echo                         >> "/home/$user/.profile"
fi
if ! grep .bashrc_local "/home/$user/.bashrc" ; then
	echo                         >> "/home/$user/.bashrc"
	echo "# Added by kinstall:"  >> "/home/$user/.bashrc"
	echo ". ~/.bashrc_local"     >> "/home/$user/.bashrc"
	echo                         >> "/home/$user/.bashrc"
fi
if ! grep .profile_local /root/.profile ; then
	echo                         >> /root/.profile
	echo "# Added by kinstall:"  >> /root/.profile
	echo ". ~/.profile_local"    >> /root/.profile
	echo                         >> /root/.profile
fi
if ! grep .bashrc_local /root/.bashrc ; then
	echo                         >> /root/.bashrc
	echo "# Added by kinstall:"  >> /root/.bashrc
	echo ". ~/.bashrc_local"     >> /root/.bashrc
	echo                         >> /root/.bashrc
fi

# Scrub away any existing apt sources, except those in /etc/apt/sources.list,
# of which we'll keep everything but the docker source.
rm -rf /etc/apt/sources.list.d
mkdir /etc/apt/sources.list.d
sed --in-place -E "s/(^deb.*docker.*)/\# \1/" /etc/apt/sources.list

# Install prereqs for using & deugging this script.
# If you add to this list, add it to apt.list too.
apt-get update
apt-get install --yes \
	apt-transport-https \
	ca-certificates \
	curl \
	git \
	gnupg-agent \
	neovim \
	software-properties-common

# Make host-specific install files if they don't exist already.
# This may dirty the git state, but that's on purpose -- setting up
# a new host is something that should be intentionally committed.
mkdir -p "/home/$user/kinstall.$host"
cp -r --no-clobber "/home/$user/kinstall/host-template"/* "/home/$user/kinstall.$host"

# Copy fs template to homedir, and merge in host-specific additions/overrides.
# Then, copy it to system root, respecting existing folders & files.
rm -rf "/home/$user/.kfs"
mkdir -p "/home/$user/.kfs"
cp -r "/home/$user/kinstall/fs"/* "/home/$user/.kfs"
cp -r "/home/$user/kinstall.$host/fs/"* "/home/$user/.kfs"
mv "/home/$user/.kfs/home/USER" "/home/$user/.kfs/home/$user"
cp -r --no-clobber "/home/$user/.kfs"/* /

# Restore ownership of all home files to regular user.
chown --recursive --no-dereference "$user" "/home/$user"

# Install remaining apt packages.
sudo apt-get update
cat "/home/$user/kinstall/apt-install.list" | sed 's/#.*//' | xargs apt-get install --yes
cat "/home/$user/kinstall.$host/apt-install.list" | sed 's/#.*//' | xargs apt-get install --yes

# Install snaps that have no good deb packages.
for snapname in $( \
		cat "/home/$user/kinstall/snap-install.list" \
			"/home/$user/kinstall.$host/snap-install.list" | \
		sed 's/#.*//' \
) ; do
	if ! snap list "$snapname" >/dev/null ; then
		snap install "$snapname"
	fi
done

# Install XSecureLock (setup is finished in user.sh)
cd /root/downloads
if [[ -d xsecurelock/.git ]]; then
	cd xsecurelock
	git fetch
	git reset --hard origin/master
else
	git clone https://github.com/google/xsecurelock
	cd xsecurelock
fi
sh autogen.sh
./configure --with-pam-service-name=common-auth
make
make install


# Run host-specific system setup.
"/home/$user/kinstall.$host/system.sh"

# Remove, upgrade & autoremove.
cat "/home/$user/kinstall/apt-remove.list" | sed 's/#.*//' | xargs apt-get remove --yes
cat "/home/$user/kinstall.$host/apt-remove.list" | sed 's/#.*//' | xargs apt-get remove --yes
apt-get upgrade --autoremove --yes

# Replace some Grub options:
# 3 second timeout, no splash screen hiding console.
if ! grep 'kinstall' /etc/default/grub ; then
	cp /etc/default/grub /etc/default/grub.bak
	sed -i '/GRUB_CMDLINE_LINUX/d' /etc/default/grub
	sed -i '/GRUB_TIMEOUT/d' /etc/default/grub
	echo                                 >> /etc/default/grub
	echo "# Added by kinstall:"          >> /etc/default/grub
	echo 'GRUB_CMDLINE_LINUX_DEFAULT=""' >> /etc/default/grub
	echo 'GRUB_CMDLINE_LINUX=""'         >> /etc/default/grub
	echo 'GRUB_TIMEOUT=3'                >> /etc/default/grub
	update-grub
fi

# Start docker daemon
groupadd docker || true
usermod -aG docker "$user"
service docker start
