FROM ubuntu:20.04

## Things that should be handled by system installer.

# System setup.
RUN echo "root:password" | chpasswd
RUN apt-get update
RUN apt-get -y install sudo
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Set up user. Xubuntu install should handle this.
RUN useradd -ms /bin/bash kyle
RUN usermod -aG sudo kyle
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/kyle-nopasswd
RUN chmod 0440 /etc/sudoers.d/kyle-nopasswd
USER kyle
WORKDIR /home/kyle

## Things that the user will need to do.

# Install prereqs.
RUN sudo apt-get -y install git make
RUN echo "To bust the cache on the git checkout, just change this number: 3"

# Checkout into root dir.
RUN git init
RUN git remote add origin https://github.com/kdmccormick/home
RUN git fetch
RUN git switch master

# Boostrap setup.
RUN make bootstrap

# Final setup steps. These don't play well with the test process,
# but we leave them here as docs. 
# RUN . ~/.profile
# RUN vi .profile_local
# RUN make complete
# RUN git remote set-url origin git@github.com:kdmccormick/home.git

## Things below this serve moreso as tests, less so as docs.

# (Pull in new changes if we've been hacking on the repo.)
RUN echo "To bust the cache on the git pull, just change this number: 5"
RUN git pull

# (See if dirs and ssh work as we want them to.)
RUN echo "export KI_SSH_PASSPHRASE=fake-ssh-password" >> ~/.profile_local
RUN make dirs
RUN . ~/.profile && make git
