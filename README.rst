Kyle's ~
--------

Setup
=====

::
    git init
    git remote add origin https://github.com/kdmccormick/home
    git fetch
    git switch master
    sudo kinstall/0_system.sh
    vi ~/.profile_private  # fill in env vars and save.
    kinstall/1_ssh.sh
    open "https://github.com/settings/ssh/new"  # log in and add key.
    kinstall/2_user.sh
    open "...." # get the passkey
    gpg --import kdmc.key
    echo -e “trust\n5\ny\n” | gpg –command-fd 0 –edit-key kdmc@pm.me
    reboot
