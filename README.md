# Kyle's ~

I version control my home diretory to make it easier to set up & reproduce my preferred Linux environment.

For the parts of my environment that can't simply be checked into this repo, the `kinstall/` dir has some scripts and files. Specialized versions of the environment can be made by creating parallel directories under `kinstall.$(hostname)`.

## Setup

* Install Xubuntu 22.04, minimal, with full-disk encryption.

* Run:

  ```bash
  git init
  git remote add origin https://github.com/kdmccormick/home
  git fetch
  git switch master
  sudo kinstall/0_system.sh
  vi ~/.profile_private
  ```

* Fill in `~/.profile_private` and save.

* Run:

  ```bash
  kinstall/1_ssh.sh
  open "https://github.com/settings/ssh/new"
  ```

* Log into GitHub and add the public ssh key.

* Run:

  ```bash
  kinstall/2_user.sh
  ```

* Place private key at `~/kdmc.key`

* Run:

  ```bash
  gpg --import ~/kdmc.key
  rm ~/kdmc.key
  echo -e “trust\n5\ny\n” | gpg –command-fd 0 –edit-key kdmc@pm.me
  reboot
  ```
