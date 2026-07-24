;;; run.el --- Batch-execute every Babel block in playground/examples.org -*- lexical-binding: t; -*-

;; Usage:
;;   emacs --batch -Q -l playground/init.el -l playground/run.el -- playground/examples.org
;;
;; Executes every source block in the given Org file (in document order) and
;; prints a PASS/FAIL summary per block, identified by its `#+name:`. Exits
;; nonzero if any block failed, so `just playground` fails loudly instead of
;; silently swallowing a broken language binding.

(require 'seq)

(unless (featurep 'octra-playground-init)
  (load (expand-file-name "init.el" (file-name-directory (or load-file-name buffer-file-name)))))

(defun octra-playground--run (file)
  "Execute every src block in FILE, returning a list of (NAME . RESULT).
RESULT is `t' on success or an error-message string on failure."
  (let ((results '())
        (n 0))
    (with-current-buffer (find-file-noselect (expand-file-name file))
      (org-mode)
      ;; `envrc-global-mode' (playground/init.el) applies the devShell
      ;; environment to this buffer synchronously via its file-visit hook.
      (org-babel-map-src-blocks (buffer-file-name)
        (setq n (1+ n))
        (let* ((element (org-element-at-point))
               (lang (org-element-property :language element))
               (name (or (org-element-property :name element)
                         (format "block-%d (%s)" n lang))))
          (condition-case err
              (progn
                (org-babel-execute-src-block)
                (push (cons name t) results))
            (error
             (push (cons name (format "%s" err)) results)))))
      (save-buffer))
    (nreverse results)))

(when noninteractive
  (let* ((args (seq-filter (lambda (a) (not (string= a "--"))) command-line-args-left))
         (file (or (car args) "playground/examples.org"))
         (results (octra-playground--run file))
         (failed (seq-filter (lambda (r) (not (eq (cdr r) t))) results)))
    (princ "\n=== Octra playground results ===\n")
    (dolist (r results)
      (princ (format "[%s] %s\n" (if (eq (cdr r) t) "PASS" "FAIL") (car r))))
    (when failed
      (princ "\n=== Failures ===\n")
      (dolist (r failed)
        (princ (format "%s: %s\n" (car r) (cdr r)))))
    (kill-emacs (if failed 1 0))))
