#!/bin/bash
echo "Add docker.io repo"
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "Apt update"
apt-get update

echo "Install utils"
apt-get -y install mc aptitude terminator
aptitude update

echo "Install desktop"
apt-get -y install x11-xserver-utils tightvncserver pidgin novnc xfce4 xubuntu-icon-theme gnome-icon-theme tango-icon-theme

echo "Install console based jabber client"
apt-get -y install finch

echo "Install docker prereqs"
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo "Install docker"
apt-get -y --allow-unauthenticated install docker-ce docker-ce-cli containerd.io

echo "Install docker-compose"
curl -s -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose