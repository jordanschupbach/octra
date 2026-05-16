{ pkgs ? import <nixpkgs> { } }:

let
  octra = import ./octra.nix { pkgs = pkgs; };
in
pkgs.stdenv.mkDerivation rec {
  pname = "octratcl";
  version = "0.0.1";

  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.swig
  ];

  buildInputs = [
    octra
    pkgs.tcl
    pkgs.tk
  ];

  configurePhase = ''
    cmake -S prebindings/octratcl -B build/octratcl -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="${octra}"
  '';

  buildPhase = ''
    cmake --build build/octratcl -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    tclVersionDir="$(${pkgs.tcl}/bin/tclsh <<< 'puts [info library]' | sed -E 's|.*/(tcl[0-9]+\\.[0-9]+).*|\\1|')"
    if [ -z "$tclVersionDir" ]; then
      echo "Could not determine Tcl version directory from [info library]" >&2
      exit 1
    fi

    pkgDir="$out/lib/$tclVersionDir"
    mkdir -p "$pkgDir"

    cp -v build/octratcl/Octra.so "$pkgDir/"
    cp -v bindings/octratcl/pkgIndex.tcl "$pkgDir/"
  '';

  meta = with pkgs.lib; {
    description = "Tcl (SWIG) bindings for the octra library.";
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
