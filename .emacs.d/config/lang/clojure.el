;; Clojure language configuration.

;; Clojure mode, CIDER, and ParEdit.
(use-package clojure-mode
  :ensure t
  :config
  (use-package cider
    :ensure t
    :bind (("<C-return>" . cider-eval-last-sexp)
           ("C-x C-r" . cider-eval-region))
    :config
    (add-hook 'before-save-hook 'cider-format-buffer))
  (add-hook 'clojure-mode-hook 'enable-paredit-mode))
