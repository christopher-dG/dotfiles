#!/usr/bin/env python3

# DISCLAIMER
# This is mostly specific to my own setup.
# This isn't meant to be general.

import datetime
import os.path
import re
import subprocess
import sys
import threading
import time

bat_path = "/sys/class/power_supply/BAT0/capacity"
bat_status_path = "/sys/class/power_supply/BAT0/status"
ping_re = re.compile("time=(\d+(?:\.\d+)?) ms")
vol_re = re.compile("Volume: front-left.*?(\d+)%")


class ResultThread(threading.Thread):
    """A really basic thread that stores its results."""
    def __init__(self, fn, label, interval, *args, **kwargs):
        self.fn = fn  # Function to run.
        self.label = label  # Display label.
        self.interval = interval  # Time between function runs.
        self.result = None  # Return value of fn.
        super(ResultThread, self).__init__(**kwargs)

    def __bool__(self):
        return self.result is not None

    def __str__(self):
        if self.result is None:
            return None
        if self.label is None:
            return str(self.result)
        return "%s: %s" % (self.label, self.result)

    def run(self):
        while True:
            try:
                self.result = self.fn()
            except Exception:
                self.result = None
            time.sleep(self.interval)


def clock():
    """Get current time."""
    return datetime.datetime.now().strftime("%F %I:%M %p")


def volume():
    """Get current volume."""
    out = subprocess.check_output(["pactl", "list", "sinks"]).decode("utf-8")
    matches = vol_re.findall(out)
    return "%d%%" % int(float(matches[-1])) if matches else None


def backlight():
    """Get backlight level."""
    with open("/sys/class/backlight/intel_backlight/max_brightness") as f:
        _max = int(f.read())
    with open("/sys/class/backlight/intel_backlight/actual_brightness") as f:
        return "%d%%" % round(100 * (int(f.read()) / _max))


def network():
    """Get network name."""
    pass


def ping():
    """Get ping in ms."""
    try:
        out = subprocess.check_output(
            ["ping", "google.ca", "-c1"],
        ).decode("utf-8")
    except Exception:
        return "Offline"
    match = ping_re.search(out)
    return "%dms" % float(match.group(1)) if match else "Offline"


def battery():
    """Get battery level."""
    with open(bat_path) as f:
        percent = "%d%%" % min(float(f.read()), 100)
    with open(bat_status_path) as f:
        status = f.read().lower()
    if status == "full":
        return "full"
    elif status == "charging":
        return "%s (c)" % percent
    else:
        return percent


def nowplaying():
    """
    Get the currently playing song in Spotify.
    Depends on baton: https://github.com/joshuathompson/baton
    """
    out = subprocess.check_output(["baton", "status"]).decode("utf-8")
    if out.startswith("Couldn't"):
        return "None"
    lines = out.split("\n")
    track = lines[0].split(" ", 1)[1]
    artist = lines[1].split(" ", 1)[1]
    song = "%s - %s" % (artist, track)
    if "paused" in lines[4].lower():
        return "%s (p)" % song
    return song


def someotherfunction():
    pass


if __name__ == "__main__":  # argv is a list of modules to disable.
    def isenabled(module, program=None):
        if module in sys.argv:
            return False
        if program is not None:
            return not subprocess.run(["which", program]).returncode
        return True

    threads = []
    if isenabled("nowplaying", program="baton"):
        threads.append(ResultThread(nowplaying, "playing", 10))
    if isenabled("volume", program="pulseaudio"):
        threads.append(ResultThread(volume, "volume", 1))
    if isenabled("backlight", program="xbacklight"):
        threads.append(ResultThread(backlight, "backlight", 1)),
    if isenabled("battery") and os.path.isfile(bat_path):
        threads.append(ResultThread(battery, "battery", 60))
    if isenabled("ping"):
        threads.append(ResultThread(ping, "ping", 5))
    if isenabled("clock"):
        threads.append(ResultThread(clock, "datetime", 60))

    for thread in threads:
        thread.start()

    while True:
        time.sleep(1)
        results = [str(thread) for thread in filter(bool, threads)]
        print(" | ".join(results).lower(), flush=True)
