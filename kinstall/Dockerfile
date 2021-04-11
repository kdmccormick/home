FROM ubuntu:20.04

RUN apt-get update
RUN apt-get -y install sudo
RUN useradd -ms /bin/bash kyle
RUN usermod -aG sudo kyle
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/kyle-nopasswd
RUN chmod 0440 /etc/sudoers.d/kyle-nopasswd
RUN echo "root:password" | chpasswd
USER kyle
WORKDIR /home/kyle
RUN sudo apt-get -y install git make
RUN echo "To bust the cache on the git checkout, just change this number: 2"

RUN git init
RUN git remote add origin https://github.com/kdmccormick/home
RUN git fetch
RUN git switch master
RUN make boostrap
RUN . ~/.profile

#RUN make ssh
#RUN git remote set-url origin git@github.com:kdmccormick/home.git
#RUN make apt-packages
#RUN make special-install

