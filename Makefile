.PHONY: all

TARGET ?= dynarray_example_c

all:
	cmake -S all -B build -DCMAKE_INSTALL_PREFIX=/usr/
	make -C build -j10

run:
	./build/examples/${TARGET}

install:
	sudo make cmake -C build install

python:
	make -C ./bindings/pyoctra
	pip install ./bindings/pyoctra/
