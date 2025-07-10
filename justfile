jobs := "10"

dev:
  @echo "Running in development mode..."
  @nix develop .

all: build

build:
  @echo "Building examples..."
  @cmake -S examples -B build/debug/examples
  @cmake --build build/debug/examples -j$(jobs) --verbose

examples:
  @echo "Building examples..."
  @cmake -S examples -B build/debug/examples
  @cmake --build build/debug/examples -j$(jobs) --verbose

run:
  @echo "Running example..."
  @./build/debug/examples/dynarray_example_cpp

test:
	./build/tests/run_tests

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

python:
  nix develop . --command bash -c "rm -rf ./bindings/pyoctra/build && cmake -S ./prebindings/pyoctra -B ./build/debug/pyoctra && cmake --build ./build/debug/pyoctra -j$(jobs) && cd ./bindings/pyoctra/ && just;"

install-r:
	just -f ./bindings/octraR/justfile install

clean-r: 
	just -f ./bindings/octraR/justfile clean

repl:
	cling ${CLING_INCLUDE_FLAGS} ${CLING_COMPILE_FLAGS} ${CLING_LINK_FLAGS}


# python:
#   nix develop . --command bash -c "cmake -S prebindings/octrapy -B build/octrapy"
#   nix develop ./bindings/octrapy/ --command bash -c "sudo pip install --user ./bindings/octrapy/"
#   nix develop ./bindings/octrapy/ --command bash -c "python ./bindings/octrapy/examples/hello_world_ex.py"
# 
# python-example:
#   python ./bindings/octrapy/examples/hello_world_ex.py

# jsdev:
#   nix develop . --command bash -c "cmake -S prebindings/octrajs -B build/octrajs"
#   nix develop ./bindings/octrajs/ --command bash -c "npm --prefix ./bindings/octrajs/ install"
#   nix develop ./bindings/octrajs/ --command bash -c "npm --prefix ./bindings/octrajs/ run build"
#   nix develop ./bindings/octrajs/

javascript:
  nix develop . --command bash -c "cmake -S prebindings/octrajs -B build/octrajs"
  nix develop . --command bash -c "cmake --build build/octrajs"
  nix develop ./bindings/octrajs/ --command bash -c "npm --prefix ./bindings/octrajs/ install"
  nix develop ./bindings/octrajs/ --command bash -c "npm --prefix ./bindings/octrajs/ run build"
  # nix develop ./bindings/octrajs/ --command bash -c "node"






