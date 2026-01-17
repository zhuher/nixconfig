;; -*- mode: emacs-lisp; lexical-binding: t; -*-
;;; package --- Summary
;;; Commentary:
;;; Code:
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
;; Elpaca
(setq elpaca-core-date '(20250728)) ;; This version of Emacs was built on 2025-07-12
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

;;When installing a package used in the init file itself,
;;e.g. a package which adds a use-package key word,
;;use the :wait recipe keyword to block until that package is installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package meow :ensure t
  :defer t
  :commands meow-global-mode
  :defines meow-mode-state-list
  :autoload (meow-motion-define-key meow-leader-define-key meow-normal-define-key)
  :custom
  (meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  :config
  (add-to-list 'meow-mode-state-list '(vterm-mode . insert))
  (add-to-list 'meow-mode-state-list '(eat-mode . insert))
  :preface
  (defun meow-setup ()
    (meow-motion-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet)
     '("w" . "C-x C-s")
     '("q" . "C-x C-c")
     '("d" . "C-x 0")
     '("b" . "C-x b")
     )
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("M-h" . windmove-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("M-j" . windmove-down)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("M-k" . windmove-up)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("M-l" . windmove-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     ;; '("z" . meow-pop-selection)
     '("z" . treesit-fold-toggle)
     '("'" . repeat)
     '("M-d" . split-window-right)
     '("M-D" . split-window-below)
     '("<escape>" . ignore)))
  :hook (elpaca-after-init .
			   (lambda ()
			     (meow-setup)
			     (meow-global-mode 1)))
  )

(use-package treesit)

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs
  :preface
  (defun new-frame-setup (frame)
    (if (display-graphic-p frame)
	(progn
	  (message "Window system")
	  )
      (progn
	(message "Not a window system")
	(set-face-background 'default "unspecified-bg" frame)
	(menu-bar-mode -1)
	)))
  :autoload new-frame-setup
  :bind
  ;; (global-set-key (kbd "<pinch>") 'ignore)
  ("C-<wheel-up>" . ignore)
  ("C-<wheel-down>" . ignore)
  ("C-x o" . ignore)
  ("M-o" . other-window)
  (("s-<return>" . toggle-frame-fullscreen))
  ("M-t" . tab-new)
  ("M-{" . tab-previous)
  ("M-}" . tab-next)
  ;; ("M-w" . tab-close)
  :ensure nil
  :init
  (setq tab-bar-show 1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  ;; (tooltip-mode -1)
  (tool-bar-mode -1)
  :config
  ;; (windmove-default-keybindings)
  (add-to-list 'default-frame-alist '(undecorated-round . t))
  ;; (add-to-list 'default-frame-alist '(menu-bar-lines . 0))
  (add-to-list 'default-frame-alist '(font . "Maple Mono"))
  (add-to-list 'default-frame-alist '(alpha-background . 0.5))
  ;; (add-to-list 'default-frame-alist '(alpha . 0)) ; makes the whole mfn frame transparent
  ;; Run for already-existing frames
  (mapc 'new-frame-setup (frame-list))
  ;; Run when a new frame is created
  (add-hook 'after-make-frame-functions 'new-frame-setup)
  (add-to-list 'display-buffer-alist
               `(,(rx (| "*compilation*"))
		 display-buffer-in-side-window
		 (side . right)
		 (slot . 0)
		 (window-parameters . ((no-delete-other-windows . t)))
		 (window-width . 80)))
  ;; (if (display-graphic-p)
  ;;     (progn
  ;; 	(ignore)
  ;; 	)
  ;;   (progn
  ;;     )
  ;;   )
  (recentf-mode 1)
  ;; Automatically reread from disk if the underlying file changes
  (global-auto-revert-mode)
  ;; Save history of minibuffer
  (savehist-mode)
  ;; Move through windows with Ctrl-<arrow keys>
  ;; (windmove-default-keybindings 'control)
  ;; Don't litter file system with *~ backup files; put them all inside
  ;; ~/.emacs.d/backup or wherever
  (defun backup-file-name (fpath)
    "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
    (let* ((backupRootDir (concat user-emacs-directory "emacs-backup/"))
           (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath)) ; remove Windows driver letter in path
           (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~"))))
      (make-directory (file-name-directory backupFilePath) t)
      backupFilePath))
  (setq make-backup-file-name-function 'backup-file-name) ; Use the above function for backups
  ;; Show the tab-bar as soon as tab-bar functions are invoked
  (when (eq system-type 'darwin) (progn
				   (setq ns-auto-hide-menu-bar nil)
				   ))
  (add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
  (add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
  (display-time-mode)
  (global-hl-line-mode 1)
  (set-face-attribute 'hl-line nil :font "Maple Mono")
  (defun my-compile-and-drop (&optional interactive) ;(https://redlib.tiekoetter.com/r/emacs/comments/1j5kosx/linting_initel_based_on_usepackage/mgnoh3b)
    "Compile buffer to check for errors, but don't write an .elc.
Temporarily override `byte-compile-warnings' to avoid nitpicking
things that work.  When called interactively, permit all warnings."
    (interactive "p")
    (when (derived-mode-p #'emacs-lisp-mode)
      (let ((byte-compile-dest-file-function (lambda (_) (null-device)))
            ;; muffle "Wrote /dev/null"
            (inhibit-message t))
	(if interactive
            (byte-compile-file (buffer-file-name))
          ;; When used as a hook, only warn about real errors
          (cl-letf (((symbol-value 'byte-compile-warnings) nil))
            (byte-compile-file (buffer-file-name)))))))
  :custom
  (global-whitespace-mode t)
  (menu-bar-mode nil)
  ;; (auto-window-vscroll nil)
  (scroll-conservatively 101)
  (flymake-show-diagnostics-at-end-of-line t) ; `fancy' causes issues with scrolling
  (dired-auto-revert-buffer t)
  (epg-pinentry-mode 'loopack)
  (xterm-mouse-mode t)
  (use-package-compute-statistics t)
  ;; (window-sides-slots '(1 0 1 0))
  (debug-on-error t)
  (ring-bell-function #'ignore)
  (inhibit-splash-screen t)
  (initial-major-mode 'fundamental-mode)
  (display-time-default-load-average 0)
  (auto-revert-avoid-polling t)
  (auto-revert-interval 5)
  (auto-revert-check-vc-info t)
  (sentence-end-double-space nil)
  (enable-recursive-minibuffers t)
  (completion-cycle-threshold 1)
  (completions-detailed t)
  (tab-always-indent 'complete)
  (completion-styles '(orderless basic initials substring partial-completion))
  (completion-auto-help 'always)
  (completions-max-height 20)
  (completions-format 'one-column)
  (completions-group t)
  (completion-auto-select 'second-tab)
  (line-number-mode t)
  (column-number-mode t)
  (x-underline-at-descent-line nil)
  (switch-to-buffer-obey-display-actions t)
  (show-trailing-whitespace nil)
  (indicate-buffer-boundaries 'left)
  ;; (mouse-wheel-tilt-scroll t)
  (mouse-wheel-flip-direction t)
  (display-line-numbers-width 3)
  (display-time-format "%a %F %T")
  (display-time-interval 1)
  ;; (x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
  (display-line-numbers-type 'relative)
  (use-short-answers t)
  (dired-kill-when-opening-new-dired-buffer t)
  (default-frame-alist nil)
  (major-mode-remap-alist '(
			    (yaml-mode . yaml-ts-mode)
			    (bash-mode . bash-ts-mode)
			    (js-mode . js-ts-mode)
			    (css-mode . css-ts-mode)
			    (python-mode . python-ts-mode)
			    (conf-toml-mode . toml-ts-mode)
			    ))
  :hook
  (;; Show the help buffer after startup
   (prog-mode . (lambda () (display-line-numbers-mode) (electric-pair-mode)))
   (text-mode . visual-line-mode)
   (after-save . my-compile-and-drop)
   ((emacs-lisp-mode) . flymake-mode)
   )
  )

(use-package which-key
  :ensure t
  :config (which-key-setup-side-window-right-bottom)
  :hook elpaca-after-init)

(use-package avy
  :ensure t
  :defines (avy-dispatch-alist avy-ring)
  :bind (;;:map global-map
         ("M-c" . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Power-ups: Embark and Consult
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Consult: Misc. enhanced commands
(use-package consult
  :ensure t
  :defer t
  :commands consult-history
  :defines consult-narrow-key
  :bind (
         ;; Drop-in replacements
         ([remap switch-to-buffer] . consult-buffer)     ; orig. switch-to-buffer
	 ([remap find-file] . consult-fd)
         ("M-y"   . consult-yank-pop)   ; orig. yank-pop
         ;; Searching
         ("M-s r" . consult-ripgrep)
         ([remap isearch-forward] . consult-line)
         ([remap isearch-forward] . consult-line)
         ("M-s L" . consult-line-multi) ; isearch to M-s s
         ("M-s o" . consult-outline)
	 ([remap imenu] . consult-imenu)
	 ([remap bookmark-jump] . consult-bookmark)
         ;; Isearch integration
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)   ; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
         ("C-s" . consult-line)            ; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)      ; needed by consult-line to detect isearch
         )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

(use-package embark-consult
  :ensure t)

(use-package ring :ensure nil :defer t :autoload ring-ref)

;; Embark: supercharged context-dependent menu; kinda like a
;; super-charged right-click.
(use-package embark
  :ensure t
  :defer t
  :after avy
  :bind ("C-c a" . embark-act)        ; bind this to an easy key to hit
  :init
  ;; Add the option to run embark when using avy
  (defun bedrock/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark))

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :defines vertico-map
  :ensure t
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  :hook elpaca-after-init)

(use-package vertico-directory
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :hook elpaca-after-init)

(use-package nerd-icons :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :defer t
  :commands nerd-icons-completion-mode
  :init (nerd-icons-completion-mode)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  )

(use-package nerd-icons-dired
  :ensure t
  :hook dired-mode)

(use-package nerd-icons-ibuffer
  :ensure t
  :hook ibuffer-mode
  :custom
  (nerd-icons-ibuffer-human-readable-size t)
  )

(use-package doom-modeline
  ;; :disabled
  :ensure t
  :hook elpaca-after-init)

(use-package punch-line
  :disabled
  :ensure (:type git :host github :repo "konrad1977/punch-line")
  :hook elpaca-after-init
  :defer t
  :init
  (setq punch-show-flycheck-info nil)
  )

(use-package ligature
  :commands global-ligature-mode
  :ensure t
  :hook
  (elpaca-after-init . (lambda ()
			 (global-ligature-mode 1)
			 (message "%s" "Enabled ligatures!")
		     ))
  )
;; Part of corfu
(use-package corfu-popupinfo
  :hook corfu-mode
  :custom
  (corfu-popupinfo-delay '(0.05 . 0.05))
  (corfu-popupinfo-hide nil)
  )

;; Corfu: Popup completion-at-point
(use-package corfu
  :ensure t
  :defines (corfu-margin-formatters corfu-map)
  :defer t
  ;; :defines corfu-margin-formatters
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 1)
  (corfu-auto-delay 0.1)
  (corfu-quit-at-boundary t);'separator)
  (corfu-quit-no-match t)
  :hook (elpaca-after-init . global-corfu-mode)
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator)
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous))
  )

(use-package nerd-icons-corfu :ensure t
  :autoload nerd-icons-corfu-formatter
  :hook (global-corfu-mode . (lambda () (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))))

(use-package eglot
  :disabled
  :commands (eglot eglot-ensure)
  :defines eglot-server-programs
  :bind (:map eglot-mode-map
	      ("C-c l r" . eglot-rename)
	      ("C-c l a" . eglot-code-actions)
	      ("C-c l =" . eglot-format-buffer)
	      )
  :defer t
  :config
  (fset #'jsonrpc--log-event #'ignore)
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; activate Eglot in referenced non-project files
  :hook ((nix-ts-mode zig-ts-mode) . eglot-ensure)
  )

(use-package lsp-mode
  :ensure t
  :defer t
  :defines (lsp-keymap-prefix lsp-file-watch-ignored-directories)
  :init
  (setq lsp-keymap-prefix "C-l")
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.jj\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.zig-cache\\'")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         ((zig-ts-mode nix-ts-mode) . lsp-deferred)
	 ;; if you want which-key integration
	 (lsp-mode . lsp-enable-which-key-integration))
  :custom
  (lsp-nix-nil-formatter ["alejandra"])
  (read-process-output-max (* 1024 1024)) ;; 1mb
  (lsp-inlay-hint-enable t)
  :commands lsp-deferred)

(use-package lsp-ui :ensure t
  :hook lsp-mode
  :defines lsp-ui-mode-map
  :custom
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-sideline-show-code-actions t)
  (lsp-ui-sideline-update-mode 'point)
  (lsp-ui-sideline-delay 0.2)
  (lsp-ui-sideline-diagnostic-max-lines 1)
  (lsp-ui-peek-enable t)
  (lsp-ui-peek-show-directory t)
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-side 'right)
  (lsp-ui-doc-delay 60)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-show-with-mouse t)
  (lsp-ui-imenu-window-fix-width t)
  (lsp-ui-imenu-auto-refresh t)
  :bind (:map lsp-ui-mode-map
	      ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
	      ([remap xref-find-references] . lsp-ui-peek-find-references)
	      )
  ;; There is a window-local jump list dedicated to cross references:
;; (lsp-ui-peek-jump-backward)
;; (lsp-ui-peek-jump-forward)
;; Other cross references:
;; (lsp-ui-peek-find-workspace-symbol "pattern 0")
;; ;; If the server supports custom cross references
;; (lsp-ui-peek-find-custom 'base "$cquery/base")
  )

(use-package rainbow-mode
  :ensure t
  :commands rainbow-mode
  :hook (elpaca-after-init . (lambda ()
			       (rainbow-mode 1)
			       (message "%s" "Enabled Rainbow-Mode!")
			       )))

(use-package aggressive-indent :disabled :ensure t :hook (elpaca-after-init . global-aggressive-indent-mode))

(use-package eshell ;(https://codeberg.org/ashton314/emacs-bedrock/src/commit/8dac13ac15f534d0b3052db58ab5ebe2b4084b66/extras/base.el#L162)
  :defer t
  :defines eshell-mode-map
  :init
  (defun bedrock/setup-eshell ()
    ;; Something funny is going on with how Eshell sets up its keymaps; this is
    ;; a work-around to make C-r bound in the keymap
    (keymap-set eshell-mode-map "C-r" 'consult-history))
  :hook (eshell-mode . bedrock/setup-eshell))

;; Eat: Emulate A Terminal
(use-package eat
  :commands (eat-project eat-eshell-mode eat-eshell-visual-command-mode)
  :ensure t
  :custom
  (eat-term-name "xterm")
  :config
  (eat-eshell-mode)                     ; use Eat to handle term codes in program output
  (eat-eshell-visual-command-mode))     ; commands like less will be handled by Eat

(use-package vterm :ensure nil
  :disabled
  )

;; Fancy completion-at-point functions; there's too much in the cape package to
;; configure here; dive in when you're comfortable!
(use-package cape
  :ensure t
  :commands (cape-dabbrev cape-file)
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Orderless: powerful completion style
(use-package orderless
  :ensure t
  :autoload orderless
  ;; :config
  ;; (setq completion-styles '(orderless))
  )

;; For help, see: https://www.masteringemacs.org/article/understanding-minibuffer-completion

;; For a fancier built-in completion option, try ido-mode,
;; icomplete-vertical, or fido-mode. See also the file extras/base.el

					;(icomplete-vertical-mode)
					;(fido-vertical-mode)
					;(setopt icomplete-delay-completions-threshold 4000)

;; We won't set these, but they're good to know about
;; (setopt indent-tabs-mode nil)
;; (setopt tab-width 4)

(use-package helpful :ensure t
  :preface
  (defun +helpful-switch-to-buffer (buffer-or-name)
    "Switch to helpful BUFFER-OR-NAME.

The logic is simple, if we are currently in the helpful buffer,
reuse it's window, otherwise create new one.

Definition stolen from https://www.d12frosted.io/posts/2019-06-26-emacs-helpful"
    (if (eq major-mode 'helpful-mode)
	(switch-to-buffer buffer-or-name)
      (pop-to-buffer buffer-or-name)))
  :bind (("C-h k" . helpful-key)
         ([remap describe-symbol] . helpful-symbol)
         ([remap describe-command] . helpful-command)
	 ([remap describe-function] . helpful-callable)
	 ([remap describe-variable] . helpful-variable)
	 )
  :custom (helpful-switch-buffer-function #'+helpful-switch-to-buffer)
  )

(use-package tramp
  :custom
  (tramp-terminal-type "xterm-ghostty")
  )

(use-package mentor
  :commands mentor
  :ensure (:type git :host github :repo "skangas/mentor")
  :custom (mentor-rtorrent-download-directory "/Volumes/t7-shield/torrents/")
  (mentor-rtorrent-keep-session t)
  (mentor-view-columns '(
			 ((mentor-download-priority-column) -3 "Pri")
			 ((mentor-download-state-column) -2 "State" mentor-download-state)
			 ((mentor-download-progress-column) -3 "Cmp" mentor-download-progress)
			 (name -20 "Name" mentor-download-name)
			 ((mentor-download-speed-up-column) -5 "Up" mentor-download-speed-up)
			 ((mentor-download-speed-down-column) -5 "Down"
			  mentor-download-speed-down)
			 ((mentor-download-size-progress-column) -20 "Size" mentor-download-size)
			 (message -40 "Message" mentor-download-message)
			 ((mentor-download-tracker-name-column) -10 "Tracker"
			  mentor-tracker-name)
			 ))
  )

(use-package treesit-fold
  :ensure (:type git :host github :repo "emacs-tree-sitter/treesit-fold")
  :commands treesit-fold-toggle
  :custom
  (treesit-fold-line-count-show t)
  (treesit-fold-line-count-format "<%d lines>")
  :hook (((nix-ts-mode zig-ts-mode) . treesit-fold-close-all)
	 (elpaca-after-init . global-treesit-fold-indicators-mode)
	 )
  )

(use-package zig-ts-mode
  :mode "\\.zig\\'"
  :ensure (:type git :host codeberg :repo "meow_king/zig-ts-mode")
  )

(use-package nix-ts-mode :ensure t
  :mode "\\.nix\\'"
  )

(use-package just-ts-mode :ensure t
  ;; ("[Mm]akefile\\'" . makefile-bsdmake-mode)
  )

(use-package catppuccin-theme :ensure t
  :defines catppuccin-flavor
  :commands catppuccin-reload
  :defer t
  :preface
  (defun load-catppuccin (appearance)
    "Load theme, taking current system APPEARANCE into consideration."
    (mapc #'disable-theme custom-enabled-themes)
    (pcase appearance
      ('light (setq catppuccin-flavor 'latte) (catppuccin-reload) (mapc 'new-frame-setup (frame-list)) (message "Appearance changed to %s." appearance))
      ('dark (setq catppuccin-flavor 'frappe) (catppuccin-reload) (mapc 'new-frame-setup (frame-list)) (message "Appearance changed to %s." appearance))))
  ;; :config (load-theme 'catppuccin :no-confirm)
  (mapc 'new-frame-setup (frame-list))
  :hook (elpaca-after-init . (lambda () (add-hook 'ns-system-appearance-change-functions #'load-catppuccin) (load-theme 'catppuccin t))))


(use-package envrc :ensure t
  :hook (elpaca-after-init . envrc-global-mode)
  )

(use-package org :ensure nil :defer t
  :custom (org-babel-load-languages '((emacs-lisp . t)
				      (shell . t)))
  )

(use-package gptel :ensure t
  :defer t
  :defines gptel-backend
  :autoload gptel-make-gh-copilot
  :init
  (setq gptel-backend (gptel-make-gh-copilot "Copilot"))
  :bind (("C-c g m" . gptel-menu))
  )

(use-package project
  :custom
  (project-mode-line t) ; show project name in modeline
  :bind (
	 ([remap project-shell] . eat-project)
	 ([remap project-echell] . eat-project)
	 )
  )

(setq gc-cons-threshold 100000000)
(provide 'init)
;;; init.el ends here
