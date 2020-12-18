let home = Sys.getenv "HOME" in
UTop.history_file_name := Some (home ^ "/.local/share/opam/utop_history");;
