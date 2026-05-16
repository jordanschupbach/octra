In this repo, each language binding is implemented as a separate submodule
under `prebindings/` and `bindings`, with its own build and test workflow. The goal is that
each language can coexist within the same repository. Each binding should feel
like a "real" native library in that ecosystem: standard layout, standard
packaging, standard test runner, and standard developer workflow. Can you
flatten the structure so that the bindings folder no longer exists and all
bindings are directly under the root of the repository? Each binding should
still have its own build and test workflow, and the C/C++ core should remain
the single source of truth. The structure should be optimized for repeatable
local development, standard packaging per language, and minimal per-language
glue. Each language should be installable in its nix environment and package
manager (e.g. PyPI for Python, CRAN for R, npm for JavaScript, etc). The
project should still be designed to be cloned and renamed via `./rename_octra
<new_project_name>`, so avoid hard-coding the project name in new places unless
it is expected to be renamed by that script.


