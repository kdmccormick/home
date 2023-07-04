# Kyle's ~

I version control my home diretory to make it easier to set up & reproduce my preferred Linux environment.

For the parts of my environment that can't simply be checked into this repo, the `kinstall/` dir has some scripts and files. Specialized versions of the environment can be made by creating parallel directories under `kinstall.$(hostname)`.

Last tested with Xubuntu 22.04 running on a ThinkPad (amd64).

## Setup

* New ThinkPad? Switch Fn and Ctrl from the boot menu.

* [Download Xubuntu](https://xubuntu.org/download/), plug in a flash drive, and run:

   ```bash
   umount /dev/<FLASH_DRIVE_DEVICE_ID>
   dd status=progress bs=1m if=xubuntu2204.iso of=/dev/<FLASH_DRIVE_DEVICE_ID>
   ```

* Eject it, reboot to flash drive. Choose minimal installation with full-disk encryption (under "Advanced").

* Boot into Xubuntu. Open a terminal, and run:

  ```bash
  cd ~
  sudo apt install -y git
  git init -b master
  git remote add origin https://github.com/kdmccormick/home
  git fetch
  git switch master -f
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

## Known Issues

* This all tries to be username-agnostic, but unfortunately many of the app-managed dotfiles hardcode '/home/kyle/...' into configuration.
