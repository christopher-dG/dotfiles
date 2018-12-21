;;; Configuration entrypoint: Set up package management and load configs.

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

(use-package auto-package-update :ensure t)
(auto-package-update-maybe)

(mapc 'load (directory-files-recursively "~/.emacs.d/config" "\.el$"))
