#!/bin/bash

# Configure new VNC session

PASSWD="firefox"

mkdir /home/$USER/.vnc
echo $PASSWD | vncpasswd -f > /home/$USER/.vnc/passwd
chown -R $USER:$USER /home/$USER/.vnc
chmod 0600 /home/$USER/.vnc/passwd

vncserver -desktop xfce -geometry 1280x720

websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 8085 localhost:5901
