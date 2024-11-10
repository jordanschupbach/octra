.PHONY: all build

TARGET ?= dynarray_example_c

all: build

build:
	cmake -S all -B build -DCMAKE_INSTALL_PREFIX=/usr/
	make -C build -j10

test:
	./build/tests/run_tests
clean:
	rm -rf build

run: build
	./build/examples/${TARGET}

memcheck: build
	valgrind ./build/examples/${TARGET}

install:
	sudo make cmake -C build install

python:
	rm -rf ./bindings/pyoctra/build
	make -C ./bindings/pyoctra

# r:
# 	swig -r -c++ -o ./bindings/octraR/src/octra_wrap.cpp ./prebindings/octraR/swig/octrar.i



install-r:
	make -C ./bindings/octraR install

clean-r: 
	make -C ./bindings/octraR clean


CLING_COMPILE_FLAGS:="-std=c++17"
CLING_LINK_FLAGS += "-I/usr/include/octra-0.0.1/"
CLING_LINK_FLAGS += "-L/usr/lib/octra-0.0.1/liboctra.so"
# CLING_LINK_FLAGS += "-loctra"


repl:
	cling ${CLING_INCLUDE_FLAGS} ${CLING_COMPILE_FLAGS} ${CLING_LINK_FLAGS}




