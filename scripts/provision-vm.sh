#!/bin/bash
# Add docker.io repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

# Install utils
apt-get -y install mc aptitude terminator
aptitude update

# Install desktop
apt-get -y install x11-xserver-utils tightvncserver pidgin novnc fxce4 xubuntu-icon-theme gnome-icon-theme tango-icon-theme

# Console based jabber client
apt-get -y install finch

# Install docker prereqs
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Install docker
apt-get -y --allow-unauthenticated install docker-ce docker-ce-cli containerd.io

# Inastall docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

usermod -aG docker $USER