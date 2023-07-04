#!/usr/bin/env bash

# Re-source profile. This normally happens upon login, but if this we are
# running the full setup sequence in this shell for the very first time,
# then the profile will have been updated since it was last sourced.
. ~/.profile

if [[ -z "$KI_SSH_PASSPHRASE" ]] || [[ -z "$KI_EMAIL" ]] ; then
	echo "error: passphrase and/or email hasn't been set in .profile_private"
	exit 
fi

# Make bash stricter.
set -euo pipefail

if ls ~/.ssh/id_rsa.pub &>/dev/null; then
	echo "~/.ssh/id_rsa.pub present. Assuming key is created correctly." >&2
	echo "If it's not, then run 'rm ~/.ssh/id_rsa.pub ~/.ssh/id_rsa'" >&2
	echo "and re-run this script." >&2
else
	echo "~/.ssh/id_rsa.pub not present. Creating now." >&2
	cmd_base="ssh-keygen -t rsa -b 4096 -C '${KI_EMAIL}' -f '$HOME/.ssh/id_rsa'"
	echo "Generating ssh key with: ${cmd_base} -N <PASSPHRASE REDACTED>" >&2
	$cmd_base -N "$KI_SSH_PASSPHRASE"
fi

echo
echo
echo
cat ~/.ssh/id_rsa.pub
echo
echo
echo
echo "^^^ That's your public key."
