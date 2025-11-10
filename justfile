jobs := "10"

dev:
    @echo "Running in development mode..."
    @nix develop .

all: build

build:
    @echo "Building examples..."
    @nix develop . --command bash -c "cmake -S . -B build/debug/"
    @nix develop . --command bash -c "cmake --build build/debug/ -j{{ jobs }} --verbose"

examples:
    @echo "Building examples..."
    @nix develop . --command bash -c "cmake -S examples -B build/debug/examples"
    @nix develop . --command bash -c "cmake --build build/debug/examples -j{{ jobs }} --verbose"

run: examples
    @echo "Running example..."
    @./build/debug/examples/dynarray_example_cpp

build-test:
    @nix develop . --command bash -c "cmake -S tests -B build/debug/tests"
    @nix develop . --command bash -c "cmake --build build/debug/tests -j{{ jobs }} --verbose"

test: build-test
    @./build/debug/tests/run_tests

clean:
    rm -rf build

clean-all:
    rm -rf build/
    rm -rf ./bindings/octrajs/build/
    rm -rf ./bindings/octrajs/node_modules/
    rm -rf ./bindings/pyoctra/pyoctra.egg-info/

memcheck: build
    valgrind ./build/examples/${TARGET}

install:
    sudo make cmake -C build install

build-python:
    nix develop . --command bash -c "rm -rf ./bindings/pyoctra/build"
    nix develop . --command bash -c "cmake -S ./prebindings/pyoctra -B ./build/debug/pyoctra"
    nix develop . --command bash -c "cmake --build ./build/debug/pyoctra -j$(jobs)"

py-repl: build-python
    nix develop . --command bash -c "cd ./bindings/pyoctra/ && just;"

install-r:
    just -f ./bindings/octraR/justfile install

clean-r:
    just -f ./bindings/octraR/justfile clean

repl:
    cling ${CLING_INCLUDE_FLAGS} ${CLING_COMPILE_FLAGS} ${CLING_LINK_FLAGS}

dotnet:
    nix develop . --command bash -c "cmake -S prebindings/OctraDotNet -B build/OctraDotNet"
    nix develop . --command bash -c "cmake --build build/OctraDotNet"
    nix develop ./bindings/OctraDotNet/ --command bash -c "cmake -S ./bindings/OctraDotNet/OctraDotNet/ -B ./bindings/OctraDotNet/OctraDotNet/build/"
    nix develop ./bindings/OctraDotNet/ --command bash -c "cmake --build ./bindings/OctraDotNet/OctraDotNet/build/"
    nix develop ./bindings/OctraDotNet/ --command bash -c "cmake --build ./bindings/OctraDotNet/OctraDotNet/build/"


js:
    nix develop . --command bash -c "cmake -S prebindings/octrajs -B build/octrajs"
    nix develop . --command bash -c "cmake --build build/octrajs"
    nix develop ./bindings/octrajs/ --command bash -c "npm --prefix ./bindings/octrajs/ install"
    nix develop ./bindings/octrajs/ --command bash -c "npm --prefix ./bindings/octrajs/ run build"
    # nix develop ./bindings/octrajs/ --command bash -c "node"

js-repl:
    nix develop ./bindings/octrajs/ --command bash -c "node"

build-r: examples
    nix develop . --command bash -c "cmake -S prebindings/octrar -B build/octrar"
    nix develop . --command bash -c "cmake --build build/octrar"

r-repl: build-r
    nix develop ./bindings/octrar/ --command bash -c "R"
    # just -f ./bindings/octrar/justfile install

build-lua:
  nix develop . --command bash -c "cmake -S prebindings/loctra -B build/loctra"
  nix develop . --command bash -c "cmake --build build/loctra"
  

lua-repl: build-lua
  nix develop ./bindings/loctra/ --command bash -c "pushd ./bindings/loctra && just && lua && popd"


build-java: examples test
    nix develop . --command bash -c "cmake -S prebindings/joctra -B build/joctra"
    nix develop . --command bash -c "cmake --build build/joctra"

