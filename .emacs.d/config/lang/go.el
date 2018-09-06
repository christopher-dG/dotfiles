;;; Go language configuration.

;; Go mode.
(use-package go-mode
  :ensure t
  :config
  (use-package go-eldoc
    :ensure t
    :config (add-hook 'go-mode-hook 'go-eldoc-setup))
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  :custom (tab-width 4))

;; Company integration (code completion).
(use-package company-go :ensure t)
;; This is a bit weird, configuration within use-package doesn't seem to work.
(add-hook 'go-mode-hook
	  (lambda ()
	    (set (make-local-variable 'company-backends) '(company-go))
	    (company-mode)))
