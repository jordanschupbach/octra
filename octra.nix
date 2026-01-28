   { pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

   let
     octra = pkgs.stdenv.mkDerivation {
       pname = "octra";
       version = "0.0.1";

       src = ./.;

       buildInputs = [ 
         pkgs.cmake 
         pkgs.gcc 
         pkgs.clang 
         pkgs.cling 
         pkgs.libxml2 
         pkgs.openssl 
       ];


       phases = [ "unpackPhase" "patchPhase" "configurePhase" "buildPhase" "installPhase" ];

       configurePhase = ''
         cmake . -B tbuild -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
       '';

       buildPhase = ''
         cmake --build tbuild -- -j1
       '';

       installPhase = ''
         cmake --install tbuild --prefix $out
       '';
      
       nativeBuildInputs = [
         pkgs.cling 
       ];
     };
   in
   octra
