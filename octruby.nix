{ pkgs ? import <nixpkgs> { } }:

let
  octra = import ./octra.nix { pkgs = pkgs; };
in
pkgs.stdenv.mkDerivation rec {
  pname = "octruby";
  version = "0.0.1";

  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = [
    pkgs.swig
    pkgs.pkg-config
    pkgs.ruby
    pkgs.gnumake
    pkgs.stdenv.cc
  ];

  buildInputs = [
    octra
  ];

  buildPhase = ''
    runHook preBuild

    export OCTRA_PREFIX="${octra}"

    mkdir -p bindings/octruby/ext/octruby bindings/octruby/lib/octruby
    swig -ruby -c++ -Iinclude \
      -o bindings/octruby/ext/octruby/octruby_wrap.cxx \
      -outdir bindings/octruby/lib/octruby \
      prebindings/octruby/src/octruby.i

    pushd bindings/octruby/ext/octruby
    ruby extconf.rb
    make -j $NIX_BUILD_CORES
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    outLib="$out/lib"
    mkdir -p "$outLib/octruby"

    cp -v bindings/octruby/lib/octruby.rb "$outLib/"

    # SWIG's generated Ruby file name depends on the module name; copy whatever it generated.
    shopt -s nullglob
    rubyRbFiles=(bindings/octruby/lib/octruby/*.rb)
    if (( ''${#rubyRbFiles[@]} )); then
      cp -v "''${rubyRbFiles[@]}" "$outLib/octruby/"
    fi
    shopt -u nullglob

    # mkmf may place the compiled extension under a subdir (e.g. ext/octruby/octruby/octruby.so).
    soPath="$(find bindings/octruby/ext/octruby -name '*.so' -print -quit)"
    if [ -z "$soPath" ]; then
      echo "Could not find built Ruby extension (.so) under bindings/octruby/ext/octruby" >&2
      find bindings/octruby/ext/octruby -maxdepth 3 -type f -print >&2
      exit 1
    fi
    cp -v "$soPath" "$outLib/octruby/octruby.so"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Ruby (SWIG) bindings for the octra library.";
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
