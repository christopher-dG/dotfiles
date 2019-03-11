#!/usr/bin/env sh

lock() {
  img="/tmp/screen.png"
  scrot "$img"
  convert -blur 0x6 "$img" "$img"
  i3lock -ui "$img"
  rm "$img"
}

if [ "$1" = "lock" ]; then
  lock
elif [ "$1" = "suspend" ]; then
  systemctl suspend
elif [ "$1" = "lock-suspend" ]; then
  lock
  systemctl suspend
else
  echo "Invalid argument"
fi
