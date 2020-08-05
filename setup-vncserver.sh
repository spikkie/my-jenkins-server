#!/bin/bash -x

# Options:
HOME=/var/lib/jenkins
VNC_CFG_HOME=${HOME}/.vnc
PASSWORD="thesecret"
DISPLAY=":10"
VNCSERVER_OPTIONS="-geometry 1024x768 -alwaysshared"
PASSWD_PATH="$HOME/.vnc/passwd"
XSTARTUP_PATH="$HOME/.vnc/xstartup"
VNCSERVER="vncserver"
VNCPASSWD="vncpasswd"
NEW_SESSION="exec gnome-session"

vncserver_stop() {
    # Kill server for this display if is running
    $VNCSERVER -clean -kill $DISPLAY
}

vncserver_start() {
    mkdir ${VNC_CFG_HOME}
    echo "$PASSWORD" | $VNCPASSWD -f > $PASSWD_PATH
    chmod 600 $PASSWD_PATH
    echo "$NEW_SESSION" > $XSTARTUP_PATH
    $VNCSERVER $DISPLAY $VNCSERVER_OPTIONS
}

#Start the server initially and configure it
vncserver_start

#Stop it again
vncserver_stop

exit
