#!/usr/bin/env sh

img=/tmp/screen.png
scrot $img
convert -blur 0x6 $img $img
i3lock -ui $img
[ "$1" = "-s" ] && systemctl suspend
rm $img
