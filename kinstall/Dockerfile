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

# Install prereqs.
RUN sudo apt-get -y install git make
RUN echo "To bust the cache on the git checkout, just change this number: 2"

# Checkout into root dir.
RUN git init
RUN git remote add origin https://github.com/kdmccormick/home
RUN git fetch
RUN git switch master

# Bootstrap.
# (next three lines could just be "make boostrap"; splitting for test performance).
RUN make apt.install.bootstrap
RUN make bootstrap.copy-root-homedir
RUN make bootstrap.source-local

#RUN make ssh
#RUN git remote set-url origin git@github.com:kdmccormick/home.git
#RUN make apt-packages
#RUN make special-install

