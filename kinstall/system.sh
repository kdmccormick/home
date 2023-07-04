#!/usr/bin/env bash

# We assume that the username is 'kyle', but this could be parameterized later.
export user=kyle
export host="$(hostname)"

# Make bash stricter and echo lines.
set -xeuo pipefail

# Source our local profile & bashrc, both for root user and regular user.
touch "/home/$user/.profile" "/home/$user/.bashrc" /root/.profile /root/.bashrc
if ! (cat "/home/$user/.profile" | grep './profile_local' ) ; then
	echo                         >> "/home/$user/.profile"
	echo "# Added by kinstall:"  >> "/home/$user/.profile"
	echo ". ~/.profile_local"    >> "/home/$user/.profile"
	echo                         >> "/home/$user/.profile"
fi
if ! (cat "/home/$user/.bashrc" | grep './bashrc' ) ; then
	echo                         >> "/home/$user/.bashrc"
	echo "# Added by kinstall:"  >> "/home/$user/.bashrc"
	echo ". ~/.bashrc_local"     >> "/home/$user/.bashrc"
	echo                         >> "/home/$user/.bashrc"
fi
if ! (cat "/root/.profile" | grep './profile_local' ) ; then
	echo                         >> "/root/.profile"
	echo "# Added by kinstall:"  >> "/root/.profile"
	echo ". ~/.profile_local"    >> "/root/.profile"
	echo                         >> "/root/.profile"
fi
if ! (cat "/root/.bashrc" | grep './bashrc' ) ; then
	echo                         >> "/root/.bashrc"
	echo "# Added by kinstall:"  >> "/root/.bashrc"
	echo ". ~/.bashrc_local"     >> "/root/.bashrc"
	echo                         >> "/root/.bashrc"
fi

# Install prereqs for using & deugging this script.
# If you add to this list, add it to apt.list too.
apt-get update
apt-get install \
	apt-transport-https \
	ca-certificates \
	curl \
	git \
	gnupg-agent \
	neovim \
	software-properties-common

# Scrub away any existing apt sources, except those in /etc/apt/sources.list,
# of which we'll keep everything but the docker source.
rm -rf /etc/apt/sources.list.d
mkdir /etc/apt/sources.list.d
sed --in-place -E "s/(^deb.*docker.*)/\# \1/" /etc/apt/sources.list

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
cp -r "/home/$user/kinstall.$host/fs/"* "/home/$kyle/.kfs"
cp -r --no-clobber "/home/$user/.kfs"/* /

# Restore ownership of all home files to regular user.
chown --recursive --no-dereference "$user" "/home/$user"

# Install remaining managed packages.
# Note: we snap install 'bare' as a no-op so that if no additional arguments
# are added, the scripts still succeeds. apt doesn't have that problem.
sudo apt-get update
cat "/home/$user/kinstall/apt-install.list" | xargs apt-get install --yes
cat "/home/$user/kinstall/snap-install.list" | xargs snap install bare
cat "/home/$user/kinstall.$host/apt-install.list" | xargs apt-get install --yes
cat "/home/$user/kinstall.$host/snap-install.list" | xargs snap install bare

# Install XSecureLock (setup is finished in user.sh)
mkdir -p "/root/downloads"
cd "/root/downloads"
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
make install

# Run host-specific system setup.
"/home/$user/kinstall.$host/system.sh"

# Remove, upgrade & autoremove.
cat "/home/$user/kinstall/apt-remove.list" | xargs apt-get remove --yes
cat "/home/$user/kinstall.$host/apt-remove.list" | xargs apt-get remove --yes
apt-get upgrade --autoremove --yes
