.PHONY: all

all:
	cmake -S all -B build
	make -C build -j10
