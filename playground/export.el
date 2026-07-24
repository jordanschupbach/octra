;;; export.el --- Export playground/examples.org to HTML and PDF -*- lexical-binding: t; -*-

;; Usage:
;;   emacs --batch -Q -l playground/init.el -l playground/export.el -- playground/examples.org
;;
;; Exports the given Org file (with its already-embedded #+RESULTS: blocks,
;; from a prior `just org-playground` run) to HTML and PDF, next to it.
;; Does not re-run any Babel code block.

(unless (featurep 'octra-playground-init)
  (load (expand-file-name "init.el" (file-name-directory (or load-file-name buffer-file-name)))))

(require 'ox-html)
(require 'ox-latex)

;; The buffer already has #+RESULTS: from `just org-playground`; don't
;; re-execute every block (slow, and would re-invoke dub/cargo/gradle/etc.)
(setq org-export-use-babel nil)

(setq org-latex-pdf-process '("tectonic --outdir=%o %f"))

(defun octra-playground--export (file tectonic-dir)
  (let ((input (expand-file-name file)))
    (with-current-buffer (find-file-noselect input)
      (org-mode)
      (setq-local org-export-with-toc t)
      (let ((html (org-html-export-to-html)))
        (princ (format "Wrote %s\n" (expand-file-name html))))
      ;; Some buffer Elpaca creates along the way ends up with `envrc-mode'
      ;; active and *becomes the current buffer*, silently replacing
      ;; PATH/exec-path with only what `.envrc' exports -- tectonic isn't
      ;; part of that (it's not in devShells.default). So the caller passes
      ;; tectonic's directory in explicitly via argv rather than this code
      ;; trying `executable-find'/`getenv', which would hit the same
      ;; corrupted state. Same shape as the NODE_PATH/OCAMLPATH/CGO_* fixes
      ;; in init.el, just sourced from argv instead of a repo-relative path.
      (let* ((exec-path (if tectonic-dir (cons tectonic-dir exec-path) exec-path))
             (process-environment (copy-sequence process-environment)))
        (when tectonic-dir
          (setenv "PATH" (concat tectonic-dir ":" (getenv "PATH"))))
        (let ((pdf (org-latex-export-to-pdf)))
          (princ (format "Wrote %s\n" (expand-file-name pdf))))))))

(when noninteractive
  (let* ((args (seq-filter (lambda (a) (not (string= a "--"))) command-line-args-left))
         (file (or (nth 0 args) "playground/examples.org"))
         (tectonic-dir (nth 1 args)))
    (octra-playground--export file tectonic-dir)))
