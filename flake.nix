{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        swig-jwe = pkgs.fetchFromGitHub {
          owner = "mmomtchev";
          repo = "swig";
          rev = "aa2e126a14c6456ab0e4b3b7bfd56c11c5a8dc02";
          sha256 = "sha256-E/sfMQQb8DFT8kxQwlqy8/hFI/JXvJDbGp7MvwseJhs=";
        };

      in {
        # nix build .#hello
        # packages.hello = pkgs.hello;

        # nix build
        # defaultPackage = self.packages.${system}.hello;

        # nix develop .#hello or nix shell .#hello
        devShells.octra = pkgs.mkShell {

          # octra developer dependencies
          buildInputs = [ 

            pkgs.just 
            pkgs.python314 
            pkgs.poetry
            pkgs.cmake 


            pkgs.gcc
            pkgs.git
            pkgs.gnumake
            pkgs.just

            (pkgs.stdenv.mkDerivation {
              name = "swig-jwe";
              src = swig-jwe;
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
            })

          ];

        };

        # nix develop or nix shell
        devShell = self.devShells.${system}.octra;
      }
    );
}




