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

;; Any custom stuff goes in this directory.
(push "~/.emacs.d/lisp" load-path)

;; Tramp is for editing files on remote systems.
(use-package tramp)
(setq tramp-default-method "ssh")

;; Put customizations in a separate file.
(setq custom-file "~/.emacs.d/customize.el")
(shell-command (concat "touch " custom-file))
(load custom-file)

;; Save backups to a single directory, not the current one.
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))

;; Disable lock file.
(setq create-lockfiles nil)

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
(global-hl-line-mode)

;; Don't freeze on C-z when not running in a terminal.
(global-set-key (kbd "C-z")
                (lambda ()
                  (interactive)
                  (unless (display-graphic-p)
                    (suspend-frame))))

;; Simpler repeat key.
(global-set-key (kbd "C-,") 'repeat)

;; Colour theme.
(use-package base16-theme
  :config (load-theme 'base16-ashes t))

;; Don't display some minor modes.
(use-package delight)

;; Font.
(set-frame-font "xos4 terminus")
(set-face-attribute 'default nil :height 140)

;; A nicer terminal emulator.
(use-package vterm)
(defun disable-line-numbers ()
  "Disable line numbers."
  (display-line-numbers-mode -1))
(add-hook 'term-mode-hook 'disable-line-numbers)
(add-hook 'vterm-mode-hook 'disable-line-numbers)
(add-hook 'vterm-mode-hook
          (lambda() (set (make-local-variable 'global-hl-line-mode) nil)))

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

;; Text size.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Projectile is for project management (finding files, etc.).
(use-package projectile
  :config (projectile-mode)
  :bind-keymap ("C-c p" . projectile-command-map))

;; Show helpful keybinding popups.
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5)
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
  (global-set-key (kbd "C-;") 'company-complete)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
  :custom company-minimum-prefix-length 1)
(use-package company-quickhelp
  :config (company-quickhelp-mode))


;; Git integrations.
(use-package magit
  :bind ("C-c g" . magit-status))
(setq auth-sources '((:source "~/.emacs.d/authinfo.gpg")))
(use-package git-gutter
  :config (global-git-gutter-mode 1)
  :delight)
(use-package magit-todos
  :config (magit-todos-mode))
(use-package forge
  :after magit)

;; Multiple cursor magic.
(use-package multiple-cursors
  :bind (("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . mc/mark-next-like-this)
         ("C-c m e" . mc/edit-lines)))

;; For jumping to definitions.
(use-package dumb-jump
  :config (dumb-jump-mode)
  :bind (("C-." . dumb-jump-go)
         ("M-." . dumb-jump-back)))

;; For jumping between windows.
(use-package ace-window
  :bind ("C-x o" . ace-window))

;; Tab width.
(setq c-basic-offset 2)
(setq sh-basic-offset 2)
(setq js-indent-level 2)

;; Config/markup/misc. languages.
(use-package dockerfile-mode)
(use-package yaml-mode)
(use-package toml-mode)
(use-package ahk-mode)

;; Julia.
(use-package julia-mode)
(use-package julia-repl)
(add-hook 'julia-mode-hook
          (lambda ()
            (julia-repl-mode)
            (local-set-key (kbd "C-C j") 'julia-repl)))

;; Python.
(use-package elpy
  :init
  (elpy-enable)
  :config
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules)))

;; Elixir.
(use-package elixir-mode)

;; Go.
(use-package go-mode
  :config
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  :custom (tab-width 2))
(use-package company-go
  :config (add-to-list 'company-backends 'company-go))
(use-package go-eldoc
  :hook (go-mode . go-eldoc-setup))
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

;; EXPERIMENT SECTION: New languages, weird plugins, etc.
