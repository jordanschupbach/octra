<p align="center">
    <h1>Octra</h1>
</p>

<p align="center">
  <img src="./assets/octra.png" alt="Logo" style="width: 30%;">
</p>

<blockquote style="text-align: center;">
  One C to rule them all, one C to find them, one C to bring them all and in the darkness...
</blockquote>

---


Octra is a C project that has bindings for a variety of languages, including
Python, R, and JavaScript. It is merely meant to be used as a kickstart
template for similar projects that need to provide bindings to multiple
languages. As such, it is permissively licensed under the Unlicense.

It uses CMake as the build system, and Just as a task runner. The project
maintains a nix flake for easy development and testing.


## 🚗 Test drive (nixos)

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
just py
just py-repl
```

#### R

```bash
just r
just r-repl
```

#### Javascript

```bash
just js
just js-repl
```

