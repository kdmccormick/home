# Kyle's ~

I version control my home diretory to make it easier to set up & reproduce my preferred Linux environment.

For the parts of my environment that can't simply be checked into this repo, the `kinstall/` dir has some scripts and files. Specialized versions of the environment can be made by creating parallel directories under `kinstall.$(hostname)`.

## Setup

* Install Xubuntu 22.04, minimal, with full-disk encryption.

* Open a terminal, and run:

  ```bash
  cd ~
  git init
  git remote add origin https://github.com/kdmccormick/home
  git fetch
  git switch master
  sudo kinstall/system.sh "$USER"
  vi ~/.profile_private
  ```

* Fill in `~/.profile_private` and save.

* Run:

  ```bash
  ensure-ssh-key | xclip -selection -c
  open "https://github.com/settings/ssh/new"
  ```

* Log into GitHub, paste in the public ssh key, name it `$(hostname)`, and save.

* Load in private GPG key for `pass` and place it at `~/kdmc.key`

* Run:

  ```bash
  kinstall/user.sh
  reboot
  ```

