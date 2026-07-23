;;; init.el --- Shared Org Babel configuration for Octra docs -*- lexical-binding: t; -*-

;; Loaded by both `docs/org-to-md.el` (batch export) and interactive Emacs
;; sessions editing files under `docs/org/`. Centralizes:
;;   - which Org Babel languages are loaded and how they're executed
;;   - the environment each language's example needs to see the `octra`
;;     bindings that aren't wired up by the Nix `docs-pages` devShell
;;     (Perl, PHP, OCaml, Go currently have no Nix derivation)

(setq package-enable-at-startup nil)

(require 'org)
(require 'ob)

(setq org-confirm-babel-evaluate nil)
;; `octra--execute-babel-best-effort' (org-to-md.el) already runs every
;; block explicitly, capturing errors and inserting results into the
;; buffer. Leaving `org-export-use-babel' t makes the exporter re-execute
;; every block a second time with no error handling of its own, which
;; clobbers the first pass's results whenever the second run hits any
;; snag (temp files, process state, ...).
(setq org-export-use-babel nil)

(defconst octra-project-root
  (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name)))
  "Absolute path to the Octra repository root.")

(defun octra--path (&rest segments)
  (apply #'file-name-concat octra-project-root segments))

;; {{{ Environment for bindings without a Nix derivation (Perl, PHP, OCaml, Go).
;; Everything else (Python, Ruby, R, Tcl, Lua, Octave, Guile, JS) is wired up
;; by the `docs-pages` Nix devShell, which already exports the right
;; PYTHONPATH/RUBYLIB/TCLLIBPATH/LUA_PATH/etc. before Emacs is started.

(let ((perl5lib (octra--path "build" "perl" "lib" "perl5")))
  (when (file-directory-p perl5lib)
    (setenv "PERL5LIB" (concat perl5lib
                                (when (getenv "PERL5LIB") (concat ":" (getenv "PERL5LIB")))))))

(let ((ocamlpath (octra--path "build" "ocaml" "prefix" "lib")))
  (when (file-directory-p ocamlpath)
    (setenv "OCAMLPATH" (concat ocamlpath
                                 (when (getenv "OCAMLPATH") (concat ":" (getenv "OCAMLPATH")))))))

(let ((octra-build (octra--path "build")))
  (when (file-directory-p octra-build)
    (setenv "LD_LIBRARY_PATH" (concat octra-build
                                       (when (getenv "LD_LIBRARY_PATH")
                                         (concat ":" (getenv "LD_LIBRARY_PATH")))))))

(setenv "CGO_CPPFLAGS" (format "-I%s" (octra--path "include")))
(setenv "CGO_LDFLAGS" (format "-L%s -loctra" (octra--path "build")))

;; Node's `require("./x")` resolves relative to the *requiring file*, which
;; for ob-js is a temp script outside the repo. NODE_PATH lets the example
;; use a bare `require("index.js")` instead.
(setenv "NODE_PATH" octra-project-root)

;; PHP: reuse the repo's `.user.ini` (loads the locally-built octraPHP
;; extension) instead of the system php.ini.
(defvar org-babel-php-command)
(let ((user-ini (octra--path ".user.ini")))
  (when (file-exists-p user-ini)
    (setq org-babel-php-command
          (format "php --php-ini %s" (shell-quote-argument user-ini)))))

;; }}}

;; {{{ Native Org Babel languages

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)
   (C . t)
   (python . t)
   (ruby . t)
   (perl . t)
   (R . t)
   (js . t)
   (octave . t)
   (php . t)
   (go . t)))

;; `C++` is ob-C's language name for C++; the docs use the more conventional
;; `cpp` tag, so alias it rather than rewrite every block.
(defalias 'org-babel-execute:cpp 'org-babel-execute:C++)
(defvaralias 'org-babel-default-header-args:cpp 'org-babel-default-header-args:C++)
(add-to-list 'org-src-lang-modes '("cpp" . c++))

;; The docs use `javascript` rather than ob-js's `js`.
(defalias 'org-babel-execute:javascript 'org-babel-execute:js)
(defvaralias 'org-babel-default-header-args:javascript 'org-babel-default-header-args:js)

;; }}}

;; {{{ Minimal custom backends
;;
;; Lua, Tcl, and Scheme have no *reliable* Org Babel backend available here:
;; Lua/Tcl have no backend in nixpkgs or upstream Org at all, and while
;; upstream ob-scheme exists (via Geiser), it drives Guile through a
;; comint/REPL session that is non-deterministic in `emacs --batch' (the
;; same block intermittently succeeds or fails with `end-of-file, Error
;; reading from stdin'). For all three, a small `org-babel-execute:LANG'
;; shim (write BODY to a temp file, run the interpreter, capture stdout) is
;; the reliable native-backend equivalent.

(defvar org-babel-default-header-args:lua '((:results . "output")))
(defun org-babel-execute:lua (body _params)
  (let ((tmp (org-babel-temp-file "octra-lua-" ".lua")))
    (with-temp-file tmp (insert body))
    (org-babel-eval (format "lua %s" (shell-quote-argument tmp)) "")))

(defvar org-babel-default-header-args:tcl '((:results . "output")))
(defun org-babel-execute:tcl (body _params)
  (let ((tmp (org-babel-temp-file "octra-tcl-" ".tcl")))
    (with-temp-file tmp (insert body))
    (org-babel-eval (format "tclsh %s" (shell-quote-argument tmp)) "")))

(defvar org-babel-default-header-args:scheme '((:results . "output")))
(defun org-babel-execute:scheme (body _params)
  (let ((tmp (org-babel-temp-file "octra-scheme-" ".scm")))
    (with-temp-file tmp (insert body))
    (org-babel-eval (format "guile --no-auto-compile %s" (shell-quote-argument tmp)) "")))

;; OCaml: no Org Babel backend either, and unlike Lua/Tcl it needs a
;; compile step (against the `octraocaml` findlib package) before running.
(defvar org-babel-default-header-args:ocaml '((:results . "output")))
(defun org-babel-execute:ocaml (body _params)
  (let* ((src (org-babel-temp-file "octra-ocaml-" ".ml"))
         (bin (concat src ".out")))
    (with-temp-file src (insert body))
    (org-babel-eval
     (format "ocamlfind ocamlopt -package octraocaml -linkpkg %s -o %s && %s"
             (shell-quote-argument src)
             (shell-quote-argument bin)
             (shell-quote-argument bin))
     "")))

;; }}}

(provide 'octra-docs-init)
