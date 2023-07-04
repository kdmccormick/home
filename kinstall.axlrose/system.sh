#!/usr/bin/env bash

# Re-source profile. This normally happens upon login, but if this we are
# running the full setup sequence in this shell for the very first time,
# then the profile may have been updated since it was last sourced.
. ~/.profile

# Make bash stricter and echo commands.
set -xeuo pipefail

cd /root/downloads

# Zoom
rm -f ./zoom_amd64.deb
wget https://zoom.us/client/latest/zoom_amd64.deb
apt-get install --yes ./zoom_amd64.deb

# MiniKube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
apt-get install minikube-linux-amd64 /usr/local/bin/minikube

