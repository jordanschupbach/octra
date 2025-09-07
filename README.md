<p align="center">
    <h1>Octra</h1>
</p>

<p align="center">
  <img src="./assets/octra.png" alt="Logo" style="width: 30%;">
</p>

<p align="center">
<blockquote style="text-align: center;">
  One C to rule them all, one C to find them, one C to bring them all and in the darkness...
</blockquote>
</p>

---

Octra is a C project that has bindings for a variety of languages, including
Python, R, and JavaScript. It is merely meant to be used as a kickstart
template for similar projects that need to provide bindings to multiple
languages. As such, it is permissively licensed under the Unlicense.

It uses CMake as the build system, and Just as a task runner. The project
maintains a nix flake for easy development and testing.

To demonstrate nontrivial examples, it provides simple implementations of
common datastructures (e.g. dynamic array) written in C and bound to all
targeted binding languages.

## 🚗 Test drive

### ❄️ NixOS

The easiest way to test drive the project is to use the provided Nix flake. You can
use the following command to enter a development shell with all dependencies:

```bash
nix develop
```

To build the project

```bash
just build
```

to run tests:

```bash
just test
```

to build examples:

```bash
just examples
```

to run TARGET example:

```bash
just run TARGET=example_name
```

## Bindings

### Test Drive

#### Python

```bash
just python
```

#### R

```bash
just build-r
just install-r
just r
```

#### Javascript

```bash
just js
just js-repl
```

## Bindings

Binding support is (to be) provided for the following languages:

| Language   | Name                                                      | Implemented |
| ---------- | --------------------------------------------------------- | ----------- |
| C#         | OctraDotNet                                               | ✖          |
| D          | DOctra                                                    | ✖          |
| Go         | Gooctra                                                   | ✖          |
| Guile      | Goctra                                                    | ✖          |
| Java       | Joctra                                                    | ✖          |
| Javascript | [OctraJS](https://www.github.com/jordanschupbach/octrajs) | ✅          |
| Lua        | Loctra                                                    | ✖          |
| OCaml      | OctraML                                                   | ✖          |
| Octave     | MOctra                                                    | ✖          |
| PHP        | OctraPHP                                                  | ✖          |
| Perl       | Poctra                                                    | ✖          |
| Python     | [PyOctra](https://www.github.com/jordanschupbach/pyoctra) | ✅          |
| R          | [OctraR](https://www.github.com/jordanschupbach/octrar)   | ✅          |
| Ruby       | RbOctra                                                   | ✖          |
| Tcl/TK     | OctraTK                                                   | ✖          |

They are linked to this repo through git submodules, so you can update source
code to submodules by running build for the respective language.
