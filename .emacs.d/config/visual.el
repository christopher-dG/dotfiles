;;; Aesthetic configuration.

;; Base16 (editor theme).
(use-package base16-theme
  :ensure t
  :config (load-theme 'base16-embers t))

;; Font.
(set-frame-font "xos4 terminus")
(set-face-attribute 'default nil :height 100)

;;Get rid of bars.
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

;; Minimal startup screen, just recent files.
(setq
 inhibit-startup-screen t
 initial-scratch-message ""
 initial-buffer-choice 'counsel-recentf)
