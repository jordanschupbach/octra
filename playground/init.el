;;; init.el --- Interactive Org Babel playground for Octra -*- lexical-binding: t; -*-

;; Usage:
;;   emacs -Q -l playground/init.el playground/examples.org         (interactive)
;;   emacs --batch -Q -l playground/init.el -l playground/run.el -- \
;;     playground/examples.org                                      (batch, see `just playground`)
;;
;; Unlike `docs/init.el` (tuned for deterministic --batch Markdown export),
;; this config is for evaluating `playground/examples.org` by hand: it uses
;; Elpaca to install/manage Emacs packages (Org itself, and `envrc`), and
;; `envrc` to pick up the Nix flake's default devShell environment via this
;; repo's `.envrc` -- so opening `playground/examples.org` in a plain Emacs
;; is enough to get every language runtime, without manually running
;; `nix develop` first.
;;
;; Nix (see flake.nix `devShells.default`) provides every language runtime,
;; compiler, and pre-built binding library. This file only ever calls those
;; tools directly (php, lua, tclsh, guile, ocamlfind, dotnet, cargo, javac,
;; dub, go) -- never a shell script -- so evaluating a code block is the
;; only step involved in "compiling" it.

(setq package-enable-at-startup nil)

;; {{{ Elpaca bootstrap (https://github.com/progfolio/elpaca)

(defconst octra-project-root
  (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name)))
  "Absolute path to the Octra repository root.")

(defun octra--path (&rest segments)
  (apply #'file-name-concat octra-project-root segments))

;; Keep Elpaca's cache inside playground/ instead of the user's real
;; ~/.emacs.d, so this config is self-contained and disposable.
(setq user-emacs-directory (octra--path "playground" ".elpaca-emacs.d"))
(unless (file-directory-p user-emacs-directory)
  (make-directory user-emacs-directory t))

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order
  '(elpaca :repo "https://github.com/progfolio/elpaca.git"
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
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (call-process "git" nil buffer t "clone"
                                         (plist-get order :repo) repo)))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                         (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                         "--eval" "(byte-compile-file \"elpaca.el\")")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Org and envrc are the only packages Elpaca needs to manage; every other
;; language "package" here is a language runtime provided by Nix, not an
;; Emacs package.
(elpaca org)
(elpaca envrc)
(elpaca-wait)

;; }}}

(require 'org)
(require 'ob)
(require 'envrc)

(setq org-confirm-babel-evaluate nil)

;; {{{ direnv: pick up the Nix flake's default devShell via .envrc

(envrc-global-mode 1)

;; }}}

;; {{{ Environment for bindings without a Nix derivation (Perl).
;; Everything else (Python, Ruby, R, Tcl, Lua, Octave, Guile, PHP's
;; interpreter, D's octrad, Rust/Java toolchains) is wired up by `envrc`
;; picking up `devShells.default` in flake.nix. Perl's binding is only ever
;; built locally (`just build-perl`), so point at that build output
;; explicitly. (OCaml/Go/JS need the same treatment -- OCAMLPATH,
;; CGO_CPPFLAGS/CGO_LDFLAGS, NODE_PATH -- but `envrc-mode` makes
;; `process-environment` buffer-local, and Org Babel's temp buffers don't
;; inherit buffer-local bindings, only dynamic `let' ones; so those three
;; set their env vars via a per-call `let' in their own backend instead of
;; a global `setenv' here. See the custom backends below.)

(let ((perl5lib (octra--path "build" "perl" "lib" "perl5")))
  (when (file-directory-p perl5lib)
    (setenv "PERL5LIB" (concat perl5lib
                                (when (getenv "PERL5LIB") (concat ":" (getenv "PERL5LIB")))))))

;; }}}

;; {{{ Native Org Babel languages

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (C . t)
   (python . t)
   (ruby . t)
   (perl . t)
   (R . t)
   (octave . t)))

;; `C++` is ob-C's language name for C++; the playground uses the more
;; conventional `cpp` tag, so alias it rather than rewrite every block.
(defalias 'org-babel-execute:cpp 'org-babel-execute:C++)
(defvaralias 'org-babel-default-header-args:cpp 'org-babel-default-header-args:C++)
(add-to-list 'org-src-lang-modes '("cpp" . c++))

;; }}}

;; {{{ Minimal custom backends
;;
;; PHP, Go, Lua, Tcl, Scheme (Guile), OCaml, C#, D, Rust, and Java have no
;; *reliable* built-in Org Babel backend available here (PHP/Go's would
;; need extra Elpaca packages just to duplicate what a two-line
;; `org-babel-eval' shim already does; Lua/Tcl have no backend in upstream
;; Org at all; Scheme's ob-scheme drives Guile through a non-deterministic
;; comint/REPL session; OCaml/C#/D/Rust/Java need a compile step first). In
;; every case the shim writes BODY to a temp file/project and invokes the
;; language's own toolchain directly -- never a wrapper shell script.

(defvar org-babel-default-header-args:php '((:results . "output")))
(defun org-babel-execute:php (body _params)
  "Run BODY as a PHP script against the locally built octraPHP extension.
`just build-php` must be run once first."
  (let ((tmp (org-babel-temp-file "octra-php-" ".php"))
        (php-ini (octra--path ".user.ini"))
        ;; `.user.ini' references the octraPHP extension with a path
        ;; relative to the process's CWD.
        (default-directory octra-project-root))
    (with-temp-file tmp (insert body))
    (org-babel-eval
     (format "php --php-ini %s %s"
             (shell-quote-argument php-ini)
             (shell-quote-argument tmp))
     "")))

;; javascript: a custom backend rather than ob-js -- ob-js's `:results
;; output' path insists on a comint session ("Session evaluation with
;; node.js is not supported" outside one), which doesn't work well in
;; --batch. `octra.hello()` et al. need NODE_PATH pointing at the repo root
;; so `require("index.js")` resolves; that's let-bound here rather than via
;; a global `setenv' because `envrc-mode' makes `process-environment'
;; buffer-local, and Org Babel's temp buffers don't inherit buffer-local
;; bindings -- only a dynamic `let' survives that switch.
(defvar org-babel-default-header-args:javascript '((:results . "output")))
(defun org-babel-execute:javascript (body _params)
  (let ((tmp (org-babel-temp-file "octra-js-" ".js"))
        (process-environment (copy-sequence process-environment)))
    (with-temp-file tmp (insert body))
    (setenv "NODE_PATH" octra-project-root)
    (org-babel-eval (format "node %s" (shell-quote-argument tmp)) "")))

(defvar org-babel-default-header-args:go '((:results . "output")))
(defun org-babel-execute:go (body _params)
  "Run BODY as a Go program using the local `octra' Go module (src/gooctra).
`go run' resolves the `octra' import via the module governing its *working
directory*, not the target file's location, so this must run with
default-directory set to src/gooctra regardless of where examples.org lives.
The temp file itself must live *outside* src/gooctra: `go run' folds in
every other .go file in the target's own directory, which would collide
with octra.go's `package octra' (it belongs to a different package than
BODY's `package main'). CGO_CPPFLAGS/CGO_LDFLAGS are let-bound for the same
reason NODE_PATH/OCAMLPATH are above (see those backends)."
  (let* ((module-dir (octra--path "src" "gooctra"))
         (src (org-babel-temp-file "octra-playground-" ".go"))
         (process-environment (copy-sequence process-environment))
         (default-directory module-dir))
    (with-temp-file src (insert body))
    (setenv "CGO_CPPFLAGS" (format "-I%s" (octra--path "include")))
    (setenv "CGO_LDFLAGS" (format "-L%s -loctra" (octra--path "build")))
    (org-babel-eval (format "go run %s" (shell-quote-argument src)) "")))

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
;; OCAMLPATH is let-bound for the same reason NODE_PATH is above: it comes
;; from a local build (`just install-ocaml`), not the Nix devShell, so a
;; global `setenv' for it doesn't survive `envrc-mode' making
;; process-environment buffer-local.
(defvar org-babel-default-header-args:ocaml '((:results . "output")))
(defun org-babel-execute:ocaml (body _params)
  (let* ((src (org-babel-temp-file "octra-ocaml-" ".ml"))
         (bin (concat src ".out"))
         (process-environment (copy-sequence process-environment))
         (ocamlpath (octra--path "build" "ocaml" "prefix" "lib")))
    (with-temp-file src (insert body))
    (setenv "OCAMLPATH" (concat ocamlpath
                                 (when (getenv "OCAMLPATH") (concat ":" (getenv "OCAMLPATH")))))
    (org-babel-eval
     (format "ocamlfind ocamlopt -package octraocaml -linkpkg %s -o %s && %s"
             (shell-quote-argument src)
             (shell-quote-argument bin)
             (shell-quote-argument bin))
     "")))

;; C#: Org includes a C# major mode but no maintained Babel backend. Execute
;; a temporary project that references the generated Octra binding instead.
(add-to-list 'org-src-lang-modes '("csharp" . csharp))
(defvar org-babel-default-header-args:csharp '((:results . "output")))
(defun org-babel-execute:csharp (body _params)
  "Run BODY as a C# program against the locally built Octra binding.
`just build-csharp' must be run once after changing the binding; it
produces the native libraries under build/dotnet/release used by DllImport."
  (let* ((native-dir (octra--path "build" "dotnet" "release"))
         (core-dir (octra--path "build" "dotnet" "release" "_deps" "octra-build"))
         (binding-project (octra--path "src" "octradotnet" "octradotnet.csproj"))
         (work-dir (make-temp-file "octra-csharp-" t))
         (project (file-name-concat work-dir "Example.csproj"))
         (source (file-name-concat work-dir "Program.cs")))
    (unless (file-exists-p (file-name-concat native-dir "liboctra_csharp.so"))
      (error "C# example needs a local native binding; run `just build-csharp` first"))
    (unwind-protect
        (progn
          (with-temp-file source (insert body))
          (with-temp-file project
            (insert (format
                     "<Project Sdk=\"Microsoft.NET.Sdk\"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework></PropertyGroup><ItemGroup><ProjectReference Include=\"%s\" /></ItemGroup></Project>"
                     binding-project)))
          (let ((process-environment (copy-sequence process-environment)))
            (setenv "LD_LIBRARY_PATH"
                    (concat native-dir ":" core-dir
                            (when (getenv "LD_LIBRARY_PATH")
                              (concat ":" (getenv "LD_LIBRARY_PATH")))))
            (org-babel-eval
             (format "dotnet run --project %s --configuration Release"
                     (shell-quote-argument project))
             "")))
      (delete-directory work-dir t))))

;; D: depend on the local, writable src/octrad checkout by path (like
;; examples/d/dub.json does) rather than the Nix-packaged `octrad`'s dub
;; registration -- dub always rebuilds a source dependency in place, and
;; the Nix store copy is read-only. `liboctra_wrap.so` (the SWIG C++
;; wrapper octra_im.d `dlopen`s at runtime) still comes from the
;; Nix-packaged `octrad` via LD_LIBRARY_PATH (see flake.nix).
(defvar org-babel-default-header-args:d '((:results . "output")))
(defun org-babel-execute:d (body _params)
  (let* ((work-dir (make-temp-file "octra-d-" t))
         (src-dir (file-name-concat work-dir "source")))
    (make-directory src-dir t)
    (with-temp-file (file-name-concat work-dir "dub.json")
      (insert (format
               "{\n  \"name\": \"octra-playground\",\n  \"description\": \"Octra playground D scratch project\",\n  \"license\": \"Unlicense\",\n  \"targetType\": \"executable\",\n  \"dependencies\": { \"octrad\": { \"path\": \"%s\" } }\n}\n"
               (octra--path "src" "octrad"))))
    (with-temp-file (file-name-concat src-dir "app.d") (insert body))
    (unwind-protect
        (org-babel-eval
         (format "dub run --root %s --compiler=ldc2 --build=release --force --quiet"
                 (shell-quote-argument work-dir))
         "")
      (delete-directory work-dir t))))

;; Rust: `cargo run --example` builds/links against the `rustoctra` crate,
;; which pkg-config-finds `octra` at build time via its build.rs.
(defvar org-babel-default-header-args:rust '((:results . "output")))
(defun org-babel-execute:rust (body _params)
  (let* ((crate-dir (octra--path "src" "rustoctra"))
         (examples-dir (file-name-concat crate-dir "examples"))
         (src (make-temp-file (expand-file-name "octra-playground-" examples-dir) nil ".rs")))
    (unwind-protect
        (progn
          (with-temp-file src (insert body))
          (org-babel-eval
           (format "cargo run --quiet --manifest-path %s --example %s"
                   (shell-quote-argument (file-name-concat crate-dir "Cargo.toml"))
                   (shell-quote-argument (file-name-base src)))
           ""))
      (when (file-exists-p src) (delete-file src)))))

;; Java: compiles/runs against a locally-built `joctra` (no Nix derivation
;; exists for it; see `just build-java`).
(defvar org-babel-default-header-args:java '((:results . "output")))
(defun org-babel-execute:java (body _params)
  (let* ((jar (octra--path "src" "joctra" "build" "libs" "joctra.jar"))
         (native-dir (octra--path "src" "joctra-octra" "build" "cmake"))
         (work-dir (make-temp-file "octra-java-" t))
         (class-name (progn
                       (unless (string-match "public class \\([A-Za-z_][A-Za-z0-9_]*\\)" body)
                         (error "Could not find a `public class' in the Java source"))
                       (match-string 1 body)))
         (source (file-name-concat work-dir (concat class-name ".java"))))
    (unless (file-exists-p jar)
      (error "Java example needs a local build; run `just build-java` first"))
    (unwind-protect
        (progn
          (with-temp-file source (insert body))
          (org-babel-eval
           (format "javac -cp %s -d %s %s && java -cp %s:%s -Djava.library.path=%s %s"
                   (shell-quote-argument jar)
                   (shell-quote-argument work-dir)
                   (shell-quote-argument source)
                   (shell-quote-argument work-dir)
                   (shell-quote-argument jar)
                   (shell-quote-argument native-dir)
                   class-name)
           ""))
      (delete-directory work-dir t))))

;; }}}

(provide 'octra-playground-init)
