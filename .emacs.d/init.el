;;; init.el --- Emacs configuration.
;;; Commentary:
;;; Flycheck is a pain.

;;; Code:

;; Package init.
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("marmalade" . "https://marmalade-repo.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))
(push "~/.emacs.d/lisp" load-path)

;; Hide some minor modes.
(use-package delight)

;; SSH for tramp.
(use-package tramp)
(setq tramp-default-method "ssh")

;; Put customizations in a separate file.
(setq custom-file "~/.emacs.d/customize.el")
(load custom-file)

;; Add common bin directories to the path, and make it easy to do on the fly.
(defun add-to-path (&optional path)
  "Add a PATH to the exec path."
  (interactive)
  (let ((path (file-truename (or path (read-directory-name "Enter a directory: " "~/")))))
    (add-to-list 'exec-path path)
    (setenv "PATH" (concat (getenv "PATH") ":" path))))
(mapc 'add-to-path
      '("/usr/local/bin" "~/.local/bin" "~/.go/bin" "~/.cargo/bin" "~/.opam/default/bin"))

;; Save backups to a single directory, not the current one.
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))

;; Never use tabs.
(setq-default indent-tabs-mode nil)

;; Zap up to but not including the char.
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; Kill/yank using the X clipboard.
(setq save-interprogram-paste-before-kill t)

;; Minimal UI: No bars.
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

;; Line and column numbers.
(global-display-line-numbers-mode)
(column-number-mode)

;; Modal editing.
(use-package god-mode)
(global-set-key (kbd "<escape>") 'god-local-mode)

;; Don't freeze on C-z when not running in a terminal.
(global-set-key (kbd "C-z")
                (lambda ()
                  (interactive)
                  (unless (display-graphic-p)
                    (suspend-frame))))

;; Simpler repeat key.
(global-set-key (kbd "C-,") 'repeat)

;; Themes and fonts.
(use-package nord-theme)
(if (daemonp)
	  (add-hook 'after-make-frame-functions
		          (lambda (frame)
			          (with-selected-frame frame
                  (load-theme 'nord t)
                  (set-frame-font "xos4 terminus"))))
	(progn
    (load-theme 'nord t)
    (set-frame-font "xos4 terminus")))

;; Text size.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Require trailing newlines.
(setq require-final-newline t)

;; Delete trailing whitespace before saving, except in Markdown mode,
;; where we only delete trailing newlines.
(add-hook 'before-save-hook
          (lambda ()
            (if (eq major-mode 'markdown-mode)
                (progn
                  (save-excursion
                    (save-restriction
                      (widen)
                      (goto-char (point-max))
                      (delete-blank-lines))))
              (delete-trailing-whitespace))))

(defun kill-all-buffers ()
  "Close all open buffers."
  (interactive)
  (mapc 'kill-buffer (buffer-list))
  (delete-other-windows))
(global-set-key (kbd "C-x K") 'kill-all-buffers)

;; Navigation/completion.
(use-package counsel
  :config
  (counsel-mode)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  :delight)
;; For some reason, using :bind here makes counsel mode not active at startup.
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-c r g") 'counsel-rg)
(global-set-key (kbd "C-x b") 'counsel-ibuffer)
;; Projectile for project management.
(use-package projectile
  :config (projectile-mode)
  :bind-keymap ("C-c p" . projectile-command-map)
  :delight '(:eval (concat " p:" (projectile-project-name))))

;; Visual stuff.
(use-package powerline
  :config (powerline-default-theme))

;; Keybinding popups.
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5)
  (which-key-enable-god-mode-support)
  :delight)

(use-package autorevert
  :config (global-auto-revert-mode)
  :delight auto-revert-mode)

;; Parenthesis magic.
(show-paren-mode)
(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode)
  :delight)
(global-set-key (kbd "C-c w") 'mark-sexp)
(global-set-key (kbd "C-c u") 'sp-unwrap-sexp)
(global-set-key (kbd "C-M-f") 'sp-forward-sexp)
(global-set-key (kbd "C-M-b") 'sp-backward-sexp)
(global-set-key (kbd "C-M-k") 'sp-kill-sexp)

;; Autocompletion.
(use-package company
  :config
  (global-company-mode)
  (global-set-key (kbd "C-;") 'company-complete)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
  :custom company-minimum-prefix-length 1)
(use-package company-math
  :config (add-to-list 'company-backends 'company-math-symbols-unicode))
(use-package company-quickhelp
  :config (company-quickhelp-mode))
(defun tabnine-enable ()
  "Enable TabNine completion in this buffer."
  (interactive)
  (add-to-list 'company-backends 'company-tabnine t)
  (message "Enabled TabNine"))
(defun tabnine-disable ()
  "Disable TabNine completion in this buffer."
  (interactive)
  (setq company-backends (remove 'company-tabnine company-backends))
  (message "Disabled TabNine"))
(use-package company-tabnine
  :custom company-tabnine-binaries-folder "~/.emacs.d/tabnine")

;; Linting.
(use-package flycheck
  :config (global-flycheck-mode)
  :delight)

;; Git integrations.
(use-package magit
  :bind ("C-c g" . magit-status))
(use-package forge)
(use-package git-gutter
  :config (global-git-gutter-mode 1)
  :delight)
(use-package magit-todos
  :config (magit-todos-mode))

;; Multiple cursor magic.
(use-package multiple-cursors
  :bind (("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . mc/mark-next-like-this)
         ("C-c m e" . mc/edit-lines)))

;; Snippets.
(use-package yasnippet
  :config (yas-global-mode 1))
(use-package yasnippet-snippets)

;; For jumping to definitions.
(use-package dumb-jump
  :config (dumb-jump-mode)
  :bind (("C-." . dumb-jump-go)
         ("M-." . dumb-jump-back)))

;; For jumping around a buffer.
(use-package ace-jump-mode
  :bind ("C-c SPC" . ace-jump-word-mode))

;; For jumping between windows.
(use-package ace-window
  :bind ("C-x o" . ace-window))

;; Tab width.
(defvar c-basic-offset)
(defvar sh-basic-offset)
(defvar js-indent-level)
(setq c-basic-offset 2)
(setq sh-basic-offset 2)
(setq js-indent-level 2)

;; Emacs anywhere popup configuration.
(defun popup-handler (_app _title _x _y w h)
  "Handle popups from Emacs Anywhere (resize to W x H)."
  (markdown-mode)
  (local-set-key (kbd "C-c C-c") 'delete-frame)
  ; TODO: Resize does not work.
  (set-frame-size (selected-frame) (/ w 5) (/ h 5) t))
(add-hook 'ea-popup-hook 'popup-handler)

;; Fun stuff.
(use-package hackernews)
(global-set-key (kbd "C-c h n") 'hackernews)
(require 'youtube)
(global-set-key (kbd "C-c y t") 'yt/search-and-play)
(global-set-key (kbd "C-c y p") 'yt/playback-toggle)
(global-set-key (kbd "C-c y q") 'yt/playback-stop)

;; Config/markup/misc. languages.
(use-package markdown-mode)
(use-package dockerfile-mode)
(use-package yaml-mode)
(use-package toml-mode)
(use-package ahk-mode)

;; Julia.
(use-package julia-repl)
(add-hook 'julia-repl-hook (lambda () (display-line-numbers-mode -1)))
(use-package julia-mode
  :config
  (add-hook 'julia-mode-hook 'tabnine-enable)
  (add-hook 'julia-mode-hook
            (lambda ()
              (julia-repl-mode)
              (local-set-key (kbd "C-C j") 'julia-repl))))
(require 'julia-dumbcompleter)

;; Python.
(use-package elpy
  :config
  (elpy-enable)
  (add-hook 'python-mode-hook 'tabnine-disable))
(use-package company-jedi
  :hook python-mode)

;; Elixir.
;; TODO: LS stuff.
(use-package alchemist)

;; Go.
(setenv "GOPATH" (file-truename "~/.go"))
(use-package go-mode
  :config
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  :custom (tab-width 2))
(use-package company-go
  :config (add-to-list 'company-backends 'company-go))
(use-package go-eldoc
  :config
  (add-hook 'go-mode-hook 'go-eldoc-setup)
  (add-hook 'go-mode-hook 'tabnine-disable))
(defun gocode-toggle ()
  "Toggle the gocode executable between the mod and non-mod versions."
  (interactive)
  (customize-set-variable
   'company-go-gocode-command
   (if (string= company-go-gocode-command "gocode-mod")
       "gocode" "gocode-mod"))
  ;; The gocode fork that works with modules is slow, so disable idle completion.
  (if (string= company-go-gocode-command "gocode-mod")
      (customize-set-variable 'company-idle-delay nil)
    (custom-reevaluate-setting 'company-idle-delay))
  (message company-go-gocode-command))

;; Rust.
(use-package rust-mode
  :config (setq rust-format-on-save t))
(use-package flycheck-rust)
(add-hook 'flycheck-mode-hook 'flycheck-rust-setup)
(use-package cargo
  :delight cargo-minor-mode)
(add-hook 'rust-mode-hook 'cargo-minor-mode)
(use-package racer
  :delight)
(add-hook 'rust-mode-hook 'racer-mode)

;; Elisp.
(add-hook 'emacs-lisp-mode 'tabnine-disable)

;; OCaml.
(use-package tuareg)
(use-package merlin)
(autoload 'merlin-mode "merlin" "Merlin mode" t)
(add-hook 'tuareg-mode-hook 'merlin-mode)
(add-hook 'caml-mode-hook 'merlin-mode)

;; Run as a server.
(server-start)

(provide 'init)

;;; init.el ends here
