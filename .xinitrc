#!/bin/sh

sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrdb -merge $HOME/.Xresources  # Load user resources.
setxkbmap -option terminate:ctrl_alt_bksp  # ctrl-alt-backspace exits X session.
command -v dunst && dunst &  # Notification manager.
command -v gebaard && gebaard -b  # Touchpad gestures.
compton -cbi.9
[ -f $HOME/.Xmodmap ] && xmodmap $HOME/.Xmodmap
[ -f $HOME/.screenlayout/default.sh ] && $HOME/.screenlayout/default.sh  # Monitor setup.

exec i3
