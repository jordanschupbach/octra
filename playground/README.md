# Octra Org Babel playground

`examples.org` has one Org Babel code block per language binding (C++ plus
every SWIG target: C#, Python, JavaScript, R, Ruby, Perl, PHP, Lua, Tcl,
Octave, Guile, OCaml, Go, D, Rust, Java). Each block calls the `octra`
library through that language's binding and can be evaluated on its own
with `C-c C-c`.

## Interactive use

```
emacs -Q -l playground/init.el playground/examples.org
```

`init.el` bootstraps [Elpaca](https://github.com/progfolio/elpaca) (which
installs Org and [envrc](https://github.com/purcell/envrc) the first time
it runs -- this needs network access once; after that Elpaca's cache under
`playground/.elpaca-emacs.d/` is reused). `envrc-mode` then picks up this
repo's `.envrc`, which activates the Nix flake's `devShells.default` --
every language runtime, compiler, and pre-built binding library comes from
there. You don't need to run `nix develop` yourself first.

A handful of bindings (C#, PHP, Perl, OCaml, Java) have no Nix derivation
and are only ever built locally; run the `just build-*` command noted above
each of those sections once before evaluating them.

## Batch use

```
just org-playground
```

Evaluates every block in document order inside `nix develop` and prints a
PASS/FAIL summary. It also saves the results back into `examples.org`, so
re-running is the way to refresh the embedded `#+RESULTS:` blocks after
changing a binding.

## Design notes

- No shell script does the compiling. Each language's own toolchain (gcc,
  php, lua, tclsh, guile, ocamlfind, dotnet, dub, cargo, javac, go) is
  invoked directly from Emacs Lisp in `init.el`; evaluating a block *is*
  the build step.
- `init.el` is intentionally separate from `docs/init.el` (used for batch
  Markdown export of `docs/org/pages/examples.org`): that one is tuned for
  deterministic `--batch` export and Nix-managed packages, this one is
  tuned for interactive use with Elpaca + envrc.
