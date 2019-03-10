;;; youtube.el --- Listen to YouTube audio inside Emacs

;;; Commentary:
;;; Some things that would be nice:
;;; - Way to configure composite keys
;;; - Queue support
;;; - Coloured search results (title one colur, artist another)
;;; - Modeline display

;;; Code:

(require 'ivy)
(require 'json)
(require 'url)

(defgroup youtube nil "Configuration options for youtube.el")
(defcustom yt/api-key "" "YouTube API key."
  :type 'string
  :group 'youtube)
(defcustom yt/num-search-results 50 "Number of search results to return."
  :type 'integer
  :group 'youtube)
(defcustom yt/player-program "mpv" "Player command."
  :type 'string
  :group 'youtube)
(defcustom yt/player-args "--no-video --really-quiet" "Player arguments."
  :type 'string
  :group 'youtube)
(defcustom yt/player-key-toggle " " "Key to toggle playback."
  :type 'string
  :group 'youtube)
(defcustom yt/player-key-stop "q" "Key to stop playback."
  :type 'string
  :group 'youtube)

(defconst yt/search-url
  "https://www.googleapis.com/youtube/v3/search?type=video&part=snippet")

(defun yt/do-search (query)
  "Get search results for QUERY."
  (with-current-buffer
      (url-retrieve-synchronously
       (url-encode-url
        (format "%s&q=%s&maxResults=%d&key=%s"
                yt/search-url query yt/num-search-results yt/api-key)))
    (goto-char (+ 1 url-http-end-of-headers))
    (json-read-object)))

(defun yt/shape-result (video)
  "Shape VIDEO into an alist with keys id, artist, and title."
  (list (cons 'id (cdr (assq 'videoId (assq 'id video))))
        (cons 'artist (cdr (assq 'channelTitle (assq 'snippet video))))
        (cons 'title (cdr (assq 'title (assq 'snippet video))))))

(defun yt/format-result (video)
  "Format VIDEO for the selection menu."
  (format "%s - %s"
          (cdr (assq 'title video))
          (cdr (assq 'artist video))))

(defun yt/play-url (url)
  "Play URL."
  (when-let ((buffer (get-buffer "*youtube*")))
    (kill-buffer buffer))
  (let* ((cmd (locate-file yt/player-program exec-path))
         (args (cons url (split-string yt/player-args)))
         (term (apply 'make-term "youtube" cmd nil args)))
    (with-current-buffer term
      (term-char-mode)
      (set-process-query-on-exit-flag (get-process "youtube") nil))))

(defun yt/search-and-play (query)
  "Search YouTube for QUERY, select a result, and play it."
  (interactive "sYouTube search query: ")
  (let* ((results (yt/do-search query))
         (videos (mapcar 'yt/shape-result (cdr (assq 'items results))))
         (candidates (mapcar (lambda (video) (cons (yt/format-result video) video)) videos))
         (selection (ivy-read "Select a video" candidates :history 'youtube-search-history))
         (video (cdr (assoc selection candidates)))
         (url (concat "https://youtube.com/watch?v=" (cdr (assq 'id video)))))
    (yt/play-url url)))

(defun yt/send-string (s)
  "Send string S to the YouTube buffer."
  (when (get-process "youtube")
    (when-let ((buffer (get-buffer "*youtube*")))
      (with-current-buffer buffer
        (term-send-raw-string s)))))

(defun yt/playback-toggle ()
  "Toggle the playback state of the player."
  (interactive)
  (yt/send-string yt/player-key-toggle))

(defun yt/playback-stop ()
  "Stop playback."
  (interactive)
  (yt/send-string yt/player-key-stop))

(provide 'youtube)

;;; youtube.el ends here
