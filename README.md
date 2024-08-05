- [octra](#orgb9a906c)
  - [Description](#org3980fe2)
- [Features of Octra](#orgdb43257)
  - [Goals of Octra](#orgb7a2cfe)
  - [Installation](#orgf6dcff5)
  - [CLI](#org7445a04)
  - [Development](#orge5caba5)
    - [Linux/OSX](#org83ce9bd)
    - [Windows](#org4f71429)
  - [Contributions](#org3c576d6)

!!!!! WARNING - This repo is under development !!!!!


<a id="orgb9a906c"></a>

# octra

One C to rule them all&#x2026; and in the darkness bind them.


<a id="org3980fe2"></a>

## Description

C is the lingua franca of programming languages. It is the language that provides the most control over the hardware and the most flexibility in programming. However, C is **not** the most user-friendly language. It is **not** the most expressive language. It is **not** the most productive language. It is **not** my favorite language (yet).

Nonetheless, C is the language that most other languages are built on. For that reason, C has first-class support in most other languages. As a consequence, making your code available available to everyone, regardless of the users favorite programming language, is most easily done with C. It's for that reason, I believe people **ought** to write libraries in C. Yes it's unsafe. But until there are better alternatives for writing libraries that cross language boundaries, C is the best we have. It is a way to bring people together, no matter the language they speak.

The purpose of Octra is to provide the build system as a template to bind your C code to as many other languages as possible. It is meant to teach. It is midly opionated, yet strives to be unopionated. If you want to propose your opinions, please do so by opening an issue and/or sending a pull request. Contributions are welcome. Octra is licensed under the [Unlicense](https://unlicense.org) license. You are free to use and modify it as you see fit.


<a id="orgdb43257"></a>

# Features of Octra

TODO


<a id="orgb7a2cfe"></a>

## Goals of Octra

Octra, as a build system, has the following unachieved goals:

-   Provide a simple, easy-to-use build system for C code to be wrapped in as

many languages as possible.

-   Provide this in a cross-platform independent way.


<a id="orgf6dcff5"></a>

## Installation

If you want to install octra, you can run one of the following commands:

```bash
# TODO
# Linux/OSX
./install.sh
```

```sh
# TODO
# Windows powershell
./install.sh
```

\`\`\`shell

./install.sh \`\`\`


<a id="org7445a04"></a>

## CLI

Octra is meant to be installed as a command line tool. The following commands may be of use to you.

```bash
# Get help
# TODO
octra --help

# Create a new project
# TODO
octra new <template-name> <project-name>
```


<a id="orge5caba5"></a>

## Development

After either running octra-cli or cloning the repository, you can run the following commands to get started developing:


<a id="org83ce9bd"></a>

### Linux/OSX

```bash
# TODO
make dev
make dev-install

# or the traditional
# TODO
# cmake -B build -DCMAKE_BUILD_TYPE=Debug
# # cmake --install
```


<a id="org4f71429"></a>

### Windows

```sh
# TODO
```


<a id="org3c576d6"></a>

## Contributions

Contributions are welcome. Please see the [CONTRIBUTING.org](CONTRIBUTING.org) file.
