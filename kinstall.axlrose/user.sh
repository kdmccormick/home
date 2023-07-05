#!/usr/bin/env bash

# Re-source profile. This normally happens upon login, but if this we are
# running the full setup sequence in this shell for the very first time,
# then the profile may have been updated since it was last sourced.
. ~/.profile

# Make bash stricter and echo commands.
set -euo pipefail


echo "Cloning all public openedx and overhangio repos."
echo "Loading repo list from GH API..."
mkdir -p ~/openedx
cd ~/openedx
while read -r org_repo ; do
	cd ~/openedx
	org="$(echo "$org_repo" | sed -E 's|/.+$||')"
	repo="$(echo "$org_repo" | sed -E 's|^.+/||')"
	echo "================================================================"
	echo "Processing $repo (from $org)..."
	if [[ -d "$HOME/openedx/$repo" ]] ; then
		cd "$repo"
		git update-index --really-refresh
		if git diff-index --quiet HEAD ; then
			echo "$repo exist with clean git state."
			echo "Refreshing from upstream..."
			set -x
			git fetch upstream
			git switch master || git switch main
			git reset --hard upstream/master || git reset --hard upstream/main
			git-cleanbranches upstream
			set +x
		else
			echo "$repo exists but its git state is dirty."
			echo "Skipping to avoid clobbering local changes."
		fi
	else
		echo "Cloning $repo..."
		set -x
		git clone "https://github.com/$org/$repo"
		cd "$repo"
		git remote rename origin upstream
		git remote add origin "git@github.com:kdmccormick/$repo"
		set +x
	fi
	echo "Done processing $repo."
done < <(
	{
		echo '['
		for page in 1 2 3 ; do
			gh api "orgs/openedx/repos?type=public&per_page=100&page=$page"
			echo ","
		done
		for page in 1 ; do
			gh api "orgs/overhangio/repos?type=public&per_page=100&page=$page"
			echo ","
		done
		echo '[] ]'
	} \
	| python -c 'import json, sys; pages = json.load(sys.stdin); print(*[repo["full_name"] for page in pages for repo in page], sep="\n")' \
	| sort
)
 
