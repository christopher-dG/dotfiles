import atexit
import os
import readline
import sys

readline.parse_and_bind("tab: complete")
readline.read_history_file(os.getenv("PYTHONHISTORY"))
atexit.register(lambda: readline.write_history_file(os.getenv("PYTHONHISTORY")))
sys.path.append("/usr/lib/python{0.major}.{0.minor}/site-packages".format(sys.version_info))
