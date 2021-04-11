FROM ubuntu:20.04

RUN apt-get update
RUN apt-get -y install sudo
RUN useradd -ms /bin/bash kyle
RUN usermod -aG sudo kyle
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/kyle-nopasswd
RUN chmod 0440 /etc/sudoers.d/kyle-nopasswd
USER kyle
WORKDIR /home/kyle

RUN sudo apt-get -y install git make
RUN git clone https://github.com/kdmccormick/home
RUN cp -r home/* .
RUN cp -r home/.[!.]* .
RUN rm -rf home
RUN ln -s /home/kyle/.kinstall/kinstall.mk Makefile
