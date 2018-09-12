;;; Generic editor configuration.

;; Ivy (command completion), Swiper (search), and Counsel (integration).
(use-package counsel
  :ensure t
  :init
  (setq ivy-use-virtual-buffers t
	enable-recursive-minibuffers t)
  :config
  (ivy-mode t)
  (global-set-key "\C-s" 'swiper))

;; Company (code completion).
(use-package company
  :ensure t
  :custom company-minimum-prefix-length 0)
;; I'm not sure why none of this can go inside the :config section.
(global-company-mode)
(define-key company-active-map (kbd "M-n") nil)
(define-key company-active-map (kbd "M-p") nil)
(define-key company-active-map (kbd "C-n") #'company-select-next)
(define-key company-active-map (kbd "C-p") #'company-select-previous)
(define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)

;; Flycheck (linting).
(use-package flycheck
  :ensure t
  :config (global-flycheck-mode))

;; which-key (keybinding popups).
(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

;; Magit (Git integration).
(use-package magit :ensure t)
(global-set-key (kbd "C-c g") 'magit-status)

;; Neotree (directory view).
(use-package neotree
  :ensure t
  :custom
  (neo-theme 'ascii))
(global-set-key (kbd "C-c t") 'neotree-toggle)

;; Rather than zapping the given char, zap up to but not including it.
(global-set-key "\M-z" 'zap-up-to-char)

;; Keybind to close all open buffers.
(global-set-key
 (kbd "C-x K")
 '(lambda ()
    (interactive)
    (mapc 'kill-buffer (buffer-list))
    (delete-other-windows)))

;; Always show line and column numbers.
(global-display-line-numbers-mode t)
(setq column-number-mode t)

;; Delete trailing whitespace before saving.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Tabs instead of spaces.
(setq-default indent-tabs-mode nil)

;; Don't clutter init.el with customizations.
(setq custom-file "~/.emacs.d/customize.el")

;; Don't clutter the working directory with backup files.
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))

;; Don't clutter the open buffer list with too many virtual buffers.
(recentf-mode 1)
(setq recentf-max-menu-items 10)
