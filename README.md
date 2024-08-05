- [octra](#org40dc1e3)
  - [Description](#orgae7fe11)
- [Features of Octra](#org93d738d)
  - [Goals of Octra](#org4b385c2)
  - [Installation](#org84d2fcc)
  - [CLI](#org26ac115)
  - [Development](#orgd66312f)
    - [Linux/OSX](#org8b5973f)

!!!!! WARNING - This repo is under development !!!!!


<a id="org40dc1e3"></a>

# octra

One C to rule them all&#x2026; and in the darkness bind them.


<a id="orgae7fe11"></a>

## Description

C is the lingua franca of programming languages. It is the language that provides the most control over the hardware and the most flexibility in programming. However, C is **not** the most user-friendly language. It is **not** the most expressive language. It is **not** the most productive language. It is **not** my favorite language (yet).

Nonetheless, C is the language that most other languages are built on. For that reason, C has first-class support in most other languages. As a consequence, making your code available available to everyone, regardless of the users favorite programming language, is most easily done with C. It's for that reason, I believe people **ought** to write libraries in C. Yes it's unsafe. But until there are better alternatives for writing libraries that cross language boundaries, C is the best we have. It is a way to bring people together, no matter the language they speak.

The purpose of Octra is to provide the build system as a template to bind your C code to as many other languages as possible. It is meant to teach. It is midly opionated, yet strives to be unopionated. If you want to propose your opinions, please do so by opening an issue and/or sending a pull request. Contributions are welcome. Octra is licensed under the [Unlicense](https://unlicense.org) license. You are free to use and modify it as you see fit.


<a id="org93d738d"></a>

# Features of Octra

TODO


<a id="org4b385c2"></a>

## Goals of Octra

Octra, as a build system, has the following unachieved goals:

-   Provide a simple, easy-to-use build system for C code to be wrapped in as

many languages as possible.

-   Provide this in a cross-platform independent way.


<a id="org84d2fcc"></a>

## Installation

If you want to install octra, you can run one of the following commands:

\`\`\`bash

./install.sh \`\`\`

\`\`\`shell

./install.sh \`\`\`


<a id="org26ac115"></a>

## CLI

Octra is meant to be installed as a command line tool. The following commands may be of use to you.

\`\`\`shell

octra &#x2013;help

octra new <template-name> <project-name> \`\`\`


<a id="orgd66312f"></a>

## Development

After either running octra-cli or cloning the repository, you can run the following commands to get started developing:


<a id="org8b5973f"></a>

### Linux/OSX

\`\`\`bash

make dev make dev-install

\`\`\`

\### Windows \`\`\`bash

\`\`\`

\## Contributions Contributions are welcome. Please see the [CONTRIBUTING.org](CONTRIBUTING.org) file.
