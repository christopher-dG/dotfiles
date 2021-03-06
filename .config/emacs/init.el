(setq custom-file "~/.config/emacs/customize.el")

;; Basic package setup.
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Load the customization file after packages have been loaded.
(when (file-exists-p custom-file) (load custom-file))

;; https://github.com/railwaycat/homebrew-emacsmacport/issues/191
(setq mac-option-modifier 'meta)
(setq mac-command-modifier 'super)

;; Colour theme.
(use-package base16-theme)

;; Parenthesis magic.
(use-package smartparens
  :config
  (require 'smartparens-config)
  :bind
  ("C-c w" . mark-sexp)
  ("C-c u" . sp-unwrap-sexp)
  ("C-M-f" . sp-forward-sexp)
  ("C-M-b" . sp-backward-sexp)
  ("C-M-k" . sp-kill-sexp)
  :delight)

(defun load-ui ()
  "Load UI stuff."
  (load-theme 'base16-gruvbox-light-hard t)
  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (scroll-bar-mode 0)
  (set-face-attribute 'default nil :height 160)
  (smartparens-global-mode)
  (show-paren-mode))
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame (load-ui))))
  (load-ui))

(defun toggle-theme ()
  "Toggle the theme from light to dark or vice versa."
  (interactive)
  (if (eq (car custom-enabled-themes) 'base16-gruvbox-light-hard)
      (load-theme 'base16-gruvbox-dark-hard t)
    (load-theme 'base16-gruvbox-light-hard t)))

;; Update packages now and then.
;; (use-package auto-package-update
;;   :custom  auto-package-update-delete-old-versions t
;;   :config (auto-package-update-maybe))

;; Tramp is for editing files on remote systems.
(use-package tramp)
(setq
 tramp-completion-reread-directory-timeout nil
 tramp-default-method "ssh"
 tramp-use-ssh-controlmaster-options nil
 remote-file-name-inhibit-cache nil
 vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)"
                              vc-ignore-dir-regexp
                              tramp-file-name-regexp))

(use-package direnv
  :config (direnv-mode))

;; Disable autosaving, backups, lock files, and bell.
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil
      ring-bell-function 'ignore)

;; Never use tabs.
(setq-default indent-tabs-mode nil)

;; Zap up to but not including the char.
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; Kill/yank using the X clipboard.
(setq save-interprogram-paste-before-kill nil)

;; Line/column numbers + current line highlighting when programming.
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'prog-mode-hook 'column-number-mode)
(add-hook 'prog-mode-hook 'global-hl-line-mode)

;; Don't freeze on C-z when not running in a terminal.
(global-set-key (kbd "C-z")
                (lambda ()
                  (interactive)
                  (unless (display-graphic-p)
                    (suspend-frame))))

;; Simpler repeat key.
(global-set-key (kbd "C-,") 'repeat)

;; Don't display some minor modes.
(use-package delight)

;; A nicer terminal emulator.
(use-package vterm)

;; Always add trailing newlines.
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
(global-set-key (kbd "C-c f s") 'toggle-frame-fullscreen)

;; Navigation/completion.
(use-package counsel
  :custom
  ivy-use-virtual-buffers t
  ivy-count-format "(%d/%d) "
  :config
  (counsel-mode)
  :bind
  ("C-s" . swiper)
  ("C-r" . swiper-backward)
  ("C-x b" . counsel-ibuffer)
  ("C-x C-f" . counsel-find-file)
  ("C-c r g" . counsel-rg)
  :delight)

;; Linting.
(use-package flycheck
  :config (global-flycheck-mode)
  :delight)
(add-hook 'flymake-mode-hook
          (lambda ()
            (setq-local flymake-mode-hook nil)
            (flymake-mode -1)))

;; Text size.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Projectile is for project management (finding files, etc.).
(use-package projectile
  :custom projectile-mode-line "Projectile"
  :config (projectile-mode)
  :bind-keymap ("C-c p" . projectile-command-map)
  :delight)

;; Show helpful keybinding popups.
(use-package which-key
  :custom which-key-idle-delay 0.5
  :config (which-key-mode)
  :delight)

;; Company is for autocompletion.
(use-package company
  :config (global-company-mode)
  :bind ("C-;" . company-complete)
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("TAB" . company-complete-common-or-cycle))
  :custom company-minimum-prefix-length 1
  :delight)
(use-package company-quickhelp
  :config (company-quickhelp-mode))

;; Git integrations.
(use-package magit
  :bind (("C-c g" . magit-status)
         ;; M-{1-4} are already used by the WM.
         ("s-1" . magit-section-show-level-1-all)
         ("s-2" . magit-section-show-level-2-all)
         ("s-3" . magit-section-show-level-3-all)
         ("s-4" . magit-section-show-level-4-all)))
(setq auth-sources '((:source "~/.config/emacs/authinfo.gpg")))
(use-package git-gutter
  :config (global-git-gutter-mode 1)
  :delight)
(use-package forge
  :after magit
  :config (forge-toggle-closed-visibility))

;; Prompt for GPG key password in the minibuffer.
(use-package pinentry)
(setq epg-pinentry-mode 'loopback)
(pinentry-start)

;; Multiple cursor magic.
(use-package multiple-cursors
  :bind (("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . mc/mark-next-like-this)
         ("C-c m e" . mc/edit-lines)))

;; For jumping to definitions.
(use-package dumb-jump)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;; For jumping between windows.
(use-package ace-window
  :custom aw-scope 'frame
  :bind ("C-x o" . ace-window))

;; Tab width.
(setq c-basic-offset 2)
(setq sh-basic-offset 2)
(setq js-indent-level 2)
(setq-default tab-width 2)

;; Documentation popups.
(use-package eldoc
  :delight)

;; Config/markup/misc. languages.
(use-package dockerfile-mode)
(use-package yaml-mode)
(use-package toml-mode)
(use-package terraform-mode
  :hook (terraform-mode . terraform-format-on-save-mode))


;; Programming languages.
(use-package julia-mode)
(use-package julia-repl
  :hook (julia-mode . julia-repl-mode)
  :config (julia-repl-set-terminal-backend 'vterm)
  :bind (:map julia-repl-mode-map
              ("C-c C-j" . julia-repl)))
(use-package elixir-mode)
(use-package go-mode
  :custom gofmt-command "goimports"
  :config
  (add-hook 'before-save-hook 'gofmt-before-save) nil t)
