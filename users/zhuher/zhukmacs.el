(defvar --backup-directory (concat user-emacs-directory "backups"))
(defvar --auto-save-directory (concat user-emacs-directory "auto-saves/"))
(if (not (file-exists-p --backup-directory))
  (make-directory --backup-directory t))
(if (not (file-exists-p --auto-save-directory))
  (make-directory --auto-save-directory t))
(setq
  backup-directory-alist `(("." . ,--backup-directory))
  auto-save-file-name-transforms
  `((".*" ,--auto-save-directory t)))
