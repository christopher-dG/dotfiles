(setq user-emacs-directory "~/.local/share/emacs")

;; Basic package setup.
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

;; Colour theme.
(use-package base16-theme
  :config (load-theme 'base16-ashes t))

;; Minimal UI: No bars.
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

;; Update packages now and then.
(use-package auto-package-update
  :custom  auto-package-update-delete-old-versions t
  :config (auto-package-update-maybe))

;; Any custom stuff goes in this directory.
(push "~/.local/share/emacs/lisp" load-path)

;; Tramp is for editing files on remote systems.
(use-package tramp
  :custom tramp-default-method "ssh")

;; Put customizations in a separate file.
(setq custom-file "~/.local/share/emacs/customize.el")
(when (file-exists-p custom-file) (load custom-file))

;; Autosaves to the same file, and save backups to a single directory.
(auto-save-visited-mode)
(setq auto-save-list-file-prefix nil)
(setq backup-directory-alist `(("." . "~/.local/share/emacs/backups")))

;; Disable lock file.
(setq create-lockfiles nil)

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

;; Font.
(set-frame-font "Monoid")
(set-face-attribute 'default nil :height 140)

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

;; Navigation/completion.
(use-package counsel
  :config
  (counsel-mode)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  :delight)
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-c r g") 'counsel-rg)
(global-set-key (kbd "C-x b") 'counsel-ibuffer)

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

;; Company is for autocompletion.
(use-package company
  :config
  (global-company-mode)
  :bind
  (("C-;" . company-complete)
   :map company-active-map
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
(setq auth-sources '((:source "~/.local/share/emacs/authinfo.gpg")))
(use-package git-gutter
  :config (global-git-gutter-mode 1)
  :delight)
(use-package magit-todos
  :config (magit-todos-mode))
(use-package forge
  :after magit
  :config (forge-toggle-closed-visibility))

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
(use-package julia-mode
  :config (add-hook 'julia-mode-hook (lambda () (eldoc-mode -1))))
(use-package julia-repl
  :hook (julia-mode . julia-repl-mode)
  :bind (:map julia-repl-mode-map
              ("C-c C-j" . julia-repl)))

(setq python-indent-guess-indent-offset-verbose nil)
(use-package elixir-mode)
(use-package go-mode
  :custom gofmt-command "goimports"
  :config
  (add-hook 'before-save-hook 'gofmt-before-save) nil t)

;; Language server protocol.
(use-package eglot
  :bind (:map eglot-mode-map
              ("C-c e f" . eglot-format)
              ("C-c e r" . eglot-rename))
  :config
  (add-to-list 'eglot-server-programs `(elixir-mode . ("lsp" "elixir")))
  (add-to-list 'eglot-server-programs `(python-mode . ("lsp" "python")))
  (add-hook 'before-save-hook
            (lambda () (when (eglot-managed-p) (eglot-format-buffer))))
  :hook ((elixir-mode go-mode julia-mode python-mode ruby-mode) . eglot-ensure))
(use-package eglot-jl
  :config (eglot-jl-init))

;; Something keeps creating this directory.
(delete-directory "~/.emacs.d")
