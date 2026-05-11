{
  lib,
  stdenv,
  python,
  fetchPypi,
  setuptools,
  buildPythonPackage,
  libxml2,
  pkg-config
}: let
in
  buildPythonPackage rec {
    pname = "pyoctra";
    version = "0.0.1";
    pyproject = true;
    src = ./.;
    build-system = [setuptools];
    meta = {
      description = "Python bindings to the octra library.";
      homepage = "https://github.com/jordanschupbac/octra";
      license = lib.licenses.unlicense;
      maintainers = with lib.maintainers; ["Jordan Schupbach"];
    };
    buildInputs = [
      pkg-config
    ];
    nativeBuildInputs = [
      pkg-config
    ];
  }
