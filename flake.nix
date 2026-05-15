{
  description = "OCTRA";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };
  inputs.php-from-source = {
    url = "path:./nix/flakes/php";
  };
  outputs =
    { self, nixpkgs, flake-utils, php-from-source, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        octra = import ./octra.nix { pkgs = pkgs; };
        phpPackage = php-from-source.packages.${system}; # Get the custom PHP package

        # {{{ Bindings

        # Swig javascript next evolution
        swig-jse  = pkgs.stdenv.mkDerivation {

              name = "swig-jse";

              src = pkgs.fetchFromGitHub {
                owner = "mmomtchev";
                repo = "swig";
                rev = "aa2e126a14c6456ab0e4b3b7bfd56c11c5a8dc02";
                sha256 = "sha256-E/sfMQQb8DFT8kxQwlqy8/hFI/JXvJDbGp7MvwseJhs=";
              };

              buildInputs = [
                pkgs.autoconf
                pkgs.automake
                pkgs.bison
                pkgs.libtool
                pkgs.pcre2
              ];

              buildPhase = ''
                ./autogen.sh
                ./configure --prefix=$out
                make
              '';

              installPhase = ''
                make install
              '';

            };


        pythonPkgs = pkgs.python3.pkgs;
        pyoctra = import ./pyoctra.nix {
          inherit (pkgs) lib stdenv fetchPypi python libxml2 pkg-config;
          inherit (pythonPkgs) buildPythonPackage setuptools;
        };


        octrajs = import ./octrajs.nix {
          inherit (pkgs) lib buildNpmPackage libxml2 pkg-config;
        };

        octrar = pkgs.rPackages.buildRPackage {
          name = "octrar";
          src = pkgs.lib.cleanSource ./.;
          buildInputs = [
            pkgs.libxml2
            pkgs.pkg-config
            pkgs.R
          ];
        };


        # }}} Bindings

        gradleWrapped = pkgs.gradle-packages.gradle.wrapped;
        joctraGradleDeps = gradleWrapped.passthru.fetchDeps {
          pkg = pkgs.stdenvNoCC.mkDerivation {
            pname = "joctra";
            version = "0.0.1";
            src = pkgs.emptyDirectory;
            installPhase = "mkdir -p $out";
          };
          data = ./nix/joctra-gradle-deps.json;
        };

      in
      {
        checks = {
          cpp = pkgs.stdenv.mkDerivation {
            name = "octra-cpp-check";
            src = pkgs.lib.cleanSource ./.;
            nativeBuildInputs = [
              pkgs.cmake
              pkgs.pkg-config
              pkgs.clang
              pkgs.gtest
            ];
            phases = [ "unpackPhase" "buildPhase" "checkPhase" "installPhase" ];
            buildPhase = ''
              cmake -S tests -B build/tests -DCMAKE_BUILD_TYPE=Release
              cmake --build build/tests -j $NIX_BUILD_CORES
            '';
            doCheck = true;
            checkPhase = ''
              ctest --test-dir build/tests --output-on-failure
            '';
            installPhase = "mkdir -p $out";
          };

          python = pkgs.stdenv.mkDerivation {
            name = "octra-python-check";
            src = pkgs.lib.cleanSource ./.;
            nativeBuildInputs = [
              (pkgs.python3.withPackages (ps: [
                self.packages.${system}.pyoctra
                ps.pytest
              ]))
            ];
            phases = [ "unpackPhase" "checkPhase" "installPhase" ];
            doCheck = true;
            checkPhase = ''
              pytest -q bindings_tests/python
            '';
            installPhase = "mkdir -p $out";
          };

          r = pkgs.stdenv.mkDerivation {
            name = "octra-r-check";
            src = pkgs.lib.cleanSource ./.;
            nativeBuildInputs = [
              pkgs.R
              pkgs.rPackages.testthat
            ];
            phases = [ "unpackPhase" "checkPhase" "installPhase" ];
            doCheck = true;
            checkPhase = ''
              if [ ! -d tests/testthat ]; then
                echo "Expected tests/testthat to exist in source tree." >&2
                echo "PWD: $PWD" >&2
                find . -maxdepth 3 -type d -print >&2
                exit 1
              fi
              R -q -e "testthat::test_local(\".\")"
            '';
            installPhase = "mkdir -p $out";
          };

          javascript = pkgs.buildNpmPackage {
            pname = "octra-javascript-check";
            version = "0.0.1";
            src = pkgs.lib.cleanSource ./.;
            npmDepsHash = "sha256-hPHfLevEm7v3hC/NhK1uF+7+UTlT7trPOuD3+f7avHY=";
            nativeBuildInputs = [
              pkgs.python3
              pkgs.pkg-config
            ];
            buildInputs = [
              pkgs.libxml2
            ];
            env.npm_config_nodedir = "${pkgs.nodejs}";
            buildPhase = ''
              runHook preBuild
              npm run build
              runHook postBuild
            '';
            doCheck = true;
            checkPhase = ''
              runHook preCheck
              npm test
              runHook postCheck
            '';
          };

          java = pkgs.stdenv.mkDerivation {
            name = "octra-java-check";
            src = pkgs.lib.cleanSource ./.;
            nativeBuildInputs = [
              gradleWrapped
              pkgs.jdk
              pkgs.cmake
              pkgs.pkg-config
            ];
            buildInputs = [
              pkgs.libxml2
            ];

            # Provide a deterministic HTTP replay cache for Gradle via mitm-cache.
            mitmCache = joctraGradleDeps;

            phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];
            configurePhase = "runHook preConfigure";
            buildPhase = ''
              cmake -S joctra-octra -B joctra-octra/build/cmake -DCMAKE_BUILD_TYPE=Release
              cmake --build joctra-octra/build/cmake -j $NIX_BUILD_CORES
              export LD_LIBRARY_PATH="$PWD/joctra-octra/build/cmake:''${LD_LIBRARY_PATH:-}"
              gradle test --no-configuration-cache
            '';
            installPhase = "mkdir -p $out";
          };

          csharp =
            let
              nativeOctra = pkgs.stdenv.mkDerivation {
                pname = "octra-csharp-native";
                version = "0.0.1";
                src = pkgs.lib.cleanSource ./.;
                nativeBuildInputs = [
                  pkgs.cmake
                  pkgs.pkg-config
                ];
                buildInputs = [
                  pkgs.libxml2
                ];
                phases = [ "unpackPhase" "buildPhase" "installPhase" ];
                buildPhase = ''
                  cmake -S octradotnet -B build -DCMAKE_BUILD_TYPE=Release
                  cmake --build build -j $NIX_BUILD_CORES
                '';
                installPhase = ''
                  mkdir -p $out/lib
                  cp -v build/liboctra_csharp.so $out/lib/
                  cp -v build/_deps/octra-build/liboctra.so $out/lib/
                '';
              };
            in
            pkgs.buildDotnetModule {
              name = "octra-csharp-check";
              src = pkgs.lib.cleanSourceWith {
                src = ./.;
                filter = path: type: builtins.baseNameOf path != "dotnet-tools.json";
              };
              dotnet-sdk = pkgs.dotnet-sdk_10;
              nugetDeps = ./nix/nuget-deps.json;
              testProjectFile = "octradotnet.tests/octradotnet.tests.csproj";
              runtimeDeps = [ nativeOctra ];
              doCheck = true;
              dontDotnetInstall = true;
              installPhase = "mkdir -p $out";
            };
        };

        packages = {
          inherit octra pyoctra octrajs octrar;

          rename-octra = pkgs.writeShellApplication {
            name = "rename-octra";
            text = ''exec "${./rename_octra}" "$@"'';
          };
        };

        apps.rename-octra = {
          type = "app";
          program = "${self.packages.${system}.rename-octra}/bin/rename-octra";
          meta = {
            description = "Rename the template project (octra -> <newname>) across files and paths.";
          };
        };

        devShells.default = pkgs.mkShell { 
          packages = [

            octra
            pkgs.just
            pkgs.lcov
            pkgs.clang 
            # pkgs.cmake 
            pkgs.hello 
            pkgs.jq 
            pkgs.libxml2 
            pkgs.pkg-config
            swig-jse
            pkgs.doctest 
            pkgs.nodejs

            (pkgs.python3.withPackages (python-pkgs:
              with python-pkgs; [
                python-lsp-server
              ]))

          ]; 
        };

        # NOTE: :( this ... seems to fail a lot
        devShells.cpp = pkgs.mkShell { 

          packages = [

            octra
            pkgs.just
            pkgs.jq 
            pkgs.lcov
            pkgs.gtest
            (pkgs.python3.withPackages (python-pkgs:
              with python-pkgs; [
                jinja2
                pygments
              ]))
            pkgs.clang 
            pkgs.libxml2 
            pkgs.pkg-config
            pkgs.cling 
            pkgs.doxygen
            pkgs.graphviz
            pkgs.doctest 
            pkgs.cmake

            # pkgs.nodejs
            # pkgs.prefetch-npm-deps
            # pkgs.nodePackages.npm

          ];
        };

        devShells.java = pkgs.mkShell { 
          packages = [
            gradleWrapped
            pkgs.jdk
            pkgs.cmake
            pkgs.just
          ];

          shellHook = ''
              export CMAKE_PATH=${pkgs.cmake}/bin/cmake
          '';


        };

        devShells.python = pkgs.mkShell { 
          packages = [
            # pkgs.cmake
            pkgs.pkg-config
            pkgs.libxml2
            pkgs.just
            (pkgs.python3.withPackages (python-pkgs:
              with python-pkgs; [
                pyoctra
                ipython
                pip
                pytest
                numpy
                matplotlib
                python-lsp-server
              ]))
          ];
        };

        devShells.jsbuild = pkgs.mkShell { 
          packages = [
            pkgs.libxml2
            pkgs.pkg-config
            pkgs.python3
            pkgs.nodejs
            pkgs.just
            pkgs.prefetch-npm-deps
            pkgs.nodePackages.npm
          ];
        };

        devShells.javascript = pkgs.mkShell { 
          packages = [
            octrajs
            pkgs.libxml2
            pkgs.pkg-config
            pkgs.python3
            pkgs.nodejs
            pkgs.just
            pkgs.prefetch-npm-deps
            pkgs.nodePackages.npm
          ];
        };

        devShells.r = pkgs.mkShell { 
          packages = [
            octrar
            pkgs.R
            pkgs.rPackages.testthat
            pkgs.pkg-config
            pkgs.libxml2
            pkgs.just
          ];
        };

        devShells.csharp = pkgs.mkShell { 
          packages = [
            pkgs.cmake
            pkgs.dotnet-sdk_10
            pkgs.mono
            pkgs.dotnet-repl
            pkgs.just
          ];
        };

        devShells.php = pkgs.mkShell { 
          packages = [
            phpPackage
            pkgs.cmake
            pkgs.just
          ];
        };
      }
    );
}



# {
#   description = "OCTRA - One C to Rule Them All";
# 
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
# 
#   outputs = { self, nixpkgs, ... }: let
#     lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
#     version = "${builtins.substring 0 8 lastModifiedDate}-${self.shortRev or "dirty"}";
#     supportedSystems = ["x86_64-linux"];
#     forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
#     nixpkgsFor = forAllSystems (system:
#       import nixpkgs {
#         inherit system;
#         overlays = [self.overlay];
#         config = {
#           allowUnfree = true;
#         };
#       }
#     );
# 
#     # Importing octra.nix and passing pkgs
#     octra = import ./octra.nix { pkgs = nixpkgsFor.x86_64-linux; };
#   
#   in {
#     overlay = final: prev: {
#       swig2 = final.fetchFromGitHub {
#         owner = "mmomtchev";
#         repo = "swig";
#         rev = "aa2e126a14c6456ab0e4b3b7bfd56c11c5a8dc02";
#         sha256 = "sha256-E/sfMQQb8DFT8kxQwlqy8/hFI/JXvJDbGp7MvwseJhs=";
#       };
#     };
# 
#     packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) octra; });
# 
#     defaultPackage = forAllSystems (system: self.packages.${system}.octra);
# 
#     devShell = forAllSystems (system: let 
#       pkgs = nixpkgsFor.${system};  # Get pkgs for the specific system
#       shell = pkgs.mkShell { 
#         buildInputs = [ self.packages.${system}.octra ]; 
#         shellHook = ''
#           export PKG_CONFIG_PATH=${self.packages.${system}.octra}/lib/pkgconfig:$PKG_CONFIG_PATH
#           echo "PKG_CONFIG_PATH set to: $PKG_CONFIG_PATH"
#         '';
#       }; 
# 
# 
#       buildInputs = [ 
#         # self.packages.${system}.octra  # Your octra package
#         octra
#         pkgs                         # Add nixpkgs itself
#         pkgs.pkg-config
#       ]; 
# 
# 
#     in shell);
# 
#     # Other configurations...
#   };
# }





#       octra = with final;
#         final.callPackage ({inShell ? false}:
#           stdenv.mkDerivation {
#             name = "octra-${version}";
# 
#             src =
#               if inShell
#               then null
#               else ./.;
# 
#             buildInputs =
#               [
#                 pkg-config
#                 libxml2
#               ]
#               ++ (
#                 if inShell
#                 then [
#                   libxml2
#                   swig
#                   jq
#                   clang
#                   cmake
#                   cling
#                   gcc
#                   git
#                   gnumake
#                   openssl
#                   lsof
#                   just
#                   valgrind
#                   lcov
#                   doctest
#                   gdb
#                   # python314
# 
#                   jetbrains.clion
#                   doxygen
#                   (pkgs.python3.withPackages (python-pkgs: [
#                     # python-pkgs.pandas
#                     # python-pkgs.requests
#                     python-pkgs.jinja2 # from docs
#                     python-pkgs.pygments # from docs
#                   ]))
# 
#                   inetutils
#                   (pkgs.stdenv.mkDerivation {
#                     name = "swig-jse";
#                     src = swig2;
#                     buildInputs = [
#                       pkgs.autoconf
#                       pkgs.automake
#                       pkgs.bison
#                       pkgs.libtool
#                       pkgs.pcre2
#                     ];
#                     buildPhase = ''
#                       ./autogen.sh
#                       ./configure --prefix=$out
#                       make
#                     '';
#                     installPhase = ''
#                       make install
#                     '';
#                   })
#                 ]
#                 else [
#                 ]
#               );
# 
#             target = "--release";
# 
#             buildPhase = "";
# 
#             doCheck = true;
# 
#             checkPhase = "";
# 
#             installPhase = ''
#               mkdir -p $out
#             '';
#           }) {};
#     };
# 
#     packages = forAllSystems (system: {inherit (nixpkgsFor.${system}) octra;});
# 
#     defaultPackage = forAllSystems (system: self.packages.${system}.octra);
# 
#     devShell = forAllSystems (system: self.packages.${system}.octra.override {inShell = true;});
# 
#     nixosModules.octra = {pkgs, ...}: {
#       nixpkgs.overlays = [self.overlay];
# 
#       systemd.services.octra = {
#         wantedBy = ["multi-user.target"];
#         serviceConfig.ExecStart = "${pkgs.octra}/bin/octra";
#       };
#     };
# 
#     checks =
#       forAllSystems
#       (
#         system:
#           with nixpkgsFor.${system}; {
#             inherit (self.packages.${system}) octra;
#             vmTest = with import (nixpkgs + "/nixos/lib/testing-python.nix") {
#               inherit system;
#             };
#               makeTest {
#                 nodes = {
#                   client = {...}: {
#                     imports = [self.nixosModules.octra];
#                   };
#                 };
# 
#                 testScript = ''
#                 '';
#               };
#           }
#       );
#   };
# }
