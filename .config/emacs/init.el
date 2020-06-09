(setq custom-file "~/.config/emacs/customize.el")

;; Basic package setup.
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("marmalade" . "https://marmalade-repo.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Load the customization file after packages have been loaded.
(when (file-exists-p custom-file) (load custom-file))

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
  (load-theme 'base16-ashes t)
  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (scroll-bar-mode 0)
  (set-frame-font "Monoid")
  (set-face-attribute 'default nil :height 140)
  (smartparens-global-mode)
  (show-paren-mode))
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame (load-ui))))
  (load-ui))

;; Update packages now and then.
(use-package auto-package-update
  :custom  auto-package-update-delete-old-versions t
  :config (auto-package-update-maybe))

;; Tramp is for editing files on remote systems.
(use-package tramp
  :custom
  tramp-completion-reread-directory-timeout nil
  tramp-default-method "ssh")
(setq remote-file-name-inhibit-cache nil
      vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)"
                                   vc-ignore-dir-regexp
                                   tramp-file-name-regexp))

(use-package direnv
  :config (direnv-mode))

;; Disable autosaving, backups, and lock files.
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;; Never use tabs.
(setq-default indent-tabs-mode nil)

;; Zap up to but not including the char.
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; Kill/yank using the X clipboard.
(setq save-interprogram-paste-before-kill t)

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

;; Update buffers when their files are updated.
(use-package autorevert
  :config (global-auto-revert-mode))

;; Company is for autocompletion.
(use-package company
  :config
  (global-company-mode)
  :bind
  ("C-;" . company-complete)
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
  :bind ("C-c g" . magit-status))
(setq auth-sources '((:source "~/.config/emacs/authinfo.gpg")))
(use-package git-gutter
  :config (global-git-gutter-mode 1)
  :delight)
(use-package magit-todos
  :config (magit-todos-mode))
(use-package forge
  :after magit
  :config (forge-toggle-closed-visibility))
(custom-set-faces
 '(magit-diff-added ((((type tty)) (:foreground "green"))))
 '(magit-diff-added-highlight ((((type tty)) (:foreground "LimeGreen"))))
 '(magit-diff-context-highlight ((((type tty)) (:foreground "default"))))
 '(magit-diff-file-heading ((((type tty)) nil)))
 '(magit-diff-removed ((((type tty)) (:foreground "red"))))
 '(magit-diff-removed-highlight ((((type tty)) (:foreground "IndianRed"))))
 '(magit-section-highlight ((((type tty)) nil))))

;; Multiple cursor magic.
(use-package multiple-cursors
  :bind (("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . mc/mark-next-like-this)
         ("C-c m e" . mc/edit-lines)))

;; For jumping to definitions.
(use-package dumb-jump
  :config (dumb-jump-mode)
  :bind (:map dumb-jump-mode-map
              ("C-." . dumb-jump-go)
              ("M-." . dumb-jump-back)))

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
(use-package ahk-mode)

;; Programming languages.
(use-package julia-mode)
(use-package julia-repl
  :load-path "lisp/julia-repl"
  :hook (julia-mode . julia-repl-mode)
  :config (setq julia-repl-terminal-backend (make-julia-repl--buffer-vterm))
  :bind (:map julia-repl-mode-map
              ("C-c C-j" . julia-repl)))
(setq python-indent-guess-indent-offset-verbose nil)
(use-package poetry)
(use-package elixir-mode)
(use-package go-mode
  :custom gofmt-command "goimports"
  :config
  (add-hook 'before-save-hook 'gofmt-before-save) nil t)

;; Language server protocol.
(use-package eglot
  :bind (:map eglot-mode-map
              ("C-c e f" . eglot-format)
              ("C-c e r" . eglot-rename)
              ("C-c e d" . eglot-find-declaration)
              ("C-c e i" . eglot-find-implementation)
              ("C-c e t" . eglot-find-typeDefinition))
  :config
  (add-to-list 'eglot-server-programs
               `(elixir-mode . ("lsp" "elixir")))
  (add-to-list 'eglot-server-programs
               `(python-mode . (lambda (_) (list "lsp" "python" (buffer-file-name)))))
  (setq-default eglot-workspace-configuration
                '((:pyls . ((:configurationSources . ["flake8"])
                            (:plugins .
                                      ((:flake8 . ((:enabled . t)
                                                   (:exclude . "*.pyi")))
                                       (:pyls_mypy . ((:enabled . t)
                                                      (:live_mode . nil)
                                                      (:strict . t)))))))
                  (:gopls . ((:usePlaceholders . t)
                             (:completeUnimported . t)))))
  (add-hook 'before-save-hook
            (lambda () (when (and (eglot-managed-p) (not (eq major-mode 'julia-mode)))
                         (eglot-format-buffer)))))
(use-package eglot-jl
  :custom eglot-jl-julia-flags (list "-J" (expand-file-name "~/.config/emacs/lsp-jl.so"))
  :config (eglot-jl-init))