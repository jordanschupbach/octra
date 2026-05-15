TARGET := "octra_ex"
BENCH_TARGET := ""
JOBS := "20"

# {{{ run commands

run: run-cpp

run-csharp: build-csharp
  nix develop .#csharp --command bash -c "LD_LIBRARY_PATH=build/dotnet/release:$LD_LIBRARY_PATH dotnet run --project ./octradotnet"

run-java: build-java
  nix develop .#java --command bash -c "gradle run --no-configuration-cache --args='{{ TARGET }}'"

run-python:
  nix develop .#python --command bash -c 'python examples/python/{{ TARGET }}.py'

run-php: build-php
  nix develop .#php --command bash -c 'php --php-ini .user.ini examples/php/octra_ex.php'

run-r: prebuild-r
  nix develop .#r --command bash -c 'Rscript examples/r/octra_ex.r'

run-javascript: build-javascript
  nix develop .#javascript --command bash -c 'node ./examples/javascript/octra_ex.js'

run-cpp: examples
    @echo "Running target {{ TARGET }}"
    ./build/debug/examples/{{ TARGET }}

run-benchmark:
    @echo "Running Benchmarks"
    ./build/benchmarks/${BENCH_TARGET}


# }}} run commands

# {{{ prebuild commands

prebuild-python:
  cd ./include && swig -c++ -python -o ../src/octra_python_wrap.cpp ../prebindings/pyoctra/src/pyoctra.i && mv ../src/octra.py ../src/pyoctra/octra.py

prebuild-javascript:
  cd ./include && swig  -javascript -typescript -napi -c++ -o ../src/octra_js_wrap.cpp ../prebindings/octrajs/src/octrajs.i

prebuild-csharp:
  find ./octradotnet -type f -name '*.cs' ! -name 'Program.cs' -exec rm {} +
  cd ./include && swig -c++ -csharp -o ../octradotnet/octra_csharp_wrap.cpp ../prebindings/octradotnet/src/octradotnet.i 

prebuild-r:
  cd ./include && swig -c++ -r -o ../src/octra_r_wrap.cpp ../prebindings/octrar/src/octrar.i && mv ../src/octrar.R ../R

# TODO:
prebuild-php:
  cd ./include && swig -c++ -php7 -o ../src/octra_php_wrap.cpp ../prebindings/octraPHP/src/octraPHP.i

prebuild-java:
  find joctra/src/main/java/js/octra/joctra -type f -name '*.java' ! -name 'App.java' ! -path 'joctra/src/main/java/js/octra/joctra/examples/*' -exec rm {} +
  cd ./include && swig -c++ -java -o ../joctra-octra/octra_java_wrap.cpp -package js.octra.joctra -outdir ../joctra/src/main/java/js/octra/joctra ../prebindings/joctra/src/joctra.i

# }}} prebuild commands

# {{{ build commands

build-php: prebuild-php
  nix develop .#php --command bash -c 'cmake -S prebindings/octraPHP -B build/octraPHP'
  nix develop .#php --command bash -c 'cmake --build build/octraPHP -j{{ JOBS }} --verbose'


build: build-debug

build-example-installed:
  nix-shell --run 'cmake -S examples -B build/debug/examples --preset=debug -DCMAKE_MAKE_PROGRAM=$(which make) -DBUILD_W_INSTALLED=ON'


build-release:
  nix develop .#cpp --command bash -c "cmake -S . -B build/release --preset=release-clang-linux-x86 -DCMAKE_MAKE_PROGRAM=$(which make)"
  ln -sf build/release/compile_commands.json compile_commands.json

build-debug:
  nix develop .#cpp --command bash -c "cmake -S . -B build/debug --preset=debug-clang-linux-x86 -DCMAKE_MAKE_PROGRAM=$(which make)"
  ln -sf build/debug/compile_commands.json compile_commands.json

build-cpp:
    @echo "Building octra"
    nix develop .#cpp --command bash -c "cmake -S . -B build"
    nix develop .#cpp --command bash -c "cmake --build build -j{{ JOBS }} --verbose"
    nix develop .#cpp --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"


build-csharp: prebuild-csharp
  nix develop .#csharp --command bash -c "cmake -S ./octradotnet -B build/dotnet/release -DCMAKE_MAKE_PROGRAM=$(which make)"
  nix develop .#csharp --command bash -c "cmake --build build/dotnet/release -j{{ JOBS }} --verbose"
  nix develop .#csharp --command bash -c "cd ./octradotnet && dotnet build"


build-javascript: prebuild-javascript
    nix develop .#jsbuild --command bash -c "npm --prefix . run build"


build-java: prebuild-java
  nix develop .#java --command bash -c "gradle cmakeBuild"
  nix develop .#java --command bash -c "gradle build"

build-dotnet:
    nix develop . --command bash -c "cmake -S prebindings/octradotnet -B build/octradotnet"
    nix develop . --command bash -c "cmake --build build/octradotnet"
    # nix develop ./bindings/octraDotNet/ --command bash -c "just --justfile ./bindings/octraDotNet/justfile build"


# }}} build commands

# {{{ repl commands

repl-javascript: prebuild-javascript build-javascript
  nix develop .#javascript --command bash -c 'node'

repl-python: prebuild-python
  nix develop .#python --command bash -c 'ipython'

repl-r: prebuild-r
  nix develop .#r --command bash -c 'R'

repl-php: build-php
  nix develop .#php --command bash -c 'php -a --php-ini .user.ini'

repl-csharp: build-csharp
  nix develop .#csharp --command bash -c "LD_LIBRARY_PATH=build/dotnet/release:$LD_LIBRARY_PATH dotnet tool install dotnet-csi && dotnet csi"

repl-java:
  nix develop .#java --command bash -c 'export LD_LIBRARY_PATH=joctra-octra/build/cmake:$LD_LIBRARY_PATH && jshell --class-path ./joctra/build/libs/joctra.jar'

repl-cpp:
  nix develop .#cpp --command bash -c 'cling $(pkg-config --cflags octra) $(pkg-config --libs-only-L octra) -loctra -std=c++17'

# }}} repl commands

# {{{ test commands

test-python-build: prebuild-python
  nix develop .#python --command bash -c 'python setup.py sdist bdist_wheel'

test-python: prebuild-python
  nix develop .#python --command bash -c 'python -m pip install -e .'
  nix develop .#python --command bash -c 'pytest -q bindings_tests/python'

test-r: prebuild-r
  nix develop .#r --command bash -c 'R -q -e "testthat::test_local(\\".\\")"'

test-csharp: build-csharp
  nix develop .#csharp --command bash -c 'LD_LIBRARY_PATH=build/dotnet/release:$LD_LIBRARY_PATH dotnet test ./octradotnet.tests'

test-java: build-java
  nix develop .#java --command bash -c 'export LD_LIBRARY_PATH=joctra-octra/build/cmake:$LD_LIBRARY_PATH && gradle test'

test-php: build-php
  nix develop .#php --command bash -c 'php -d assert.exception=1 -d zend.assertions=1 --php-ini .user.ini bindings_tests/php/test_octra.php'


test-javascript: build-javascript
    @echo "Running Javascript Tests"
    nix develop .#javascript --command bash -c "npm run test"


test-cpp:
    @echo "Running Tests"
    nix develop .#cpp --command bash -c "cmake -S tests -B build/debug/tests --preset=debug -DCMAKE_MAKE_PROGRAM=$(which make)"
    nix develop .#cpp --command bash -c "cmake --build build/debug/tests -j{{ JOBS }} --verbose"
    nix develop .#cpp --command bash -c "find ./build/ -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
    ./build/debug/tests/run_tests


# }}} test commands

# {{{ utilities

rename NEW:
  ./rename_octra {{ NEW }}

jq:
    nix develop . --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"


playground:
    @echo "Building playground"
    nix develop .#cpp --command bash -c "cmake -S playground -B build/debug/playground"
    nix develop .#cpp --command bash -c "cmake --build build/debug/playground -j {{JOBS}} --verbose"
    ./build/debug/playground/playground_cpp

flamechart:
    @echo "Running Performance Tests"
    @perf record -F 99 -g ./build/examples/${TARGET}
    @perf script > out.perf
    @if [ ! -d "Flamegraph" ]; then \
    	git clone https://github.com/brendangregg/Flamegraph.git; \
    fi
    @./Flamegraph/stackcollapse-perf.pl out.perf > out.folded
    @./Flamegraph/flamegraph.pl out.folded > flamegraph.svg


benchmark:
    @echo "Building Examples"
    cmake -S benchmarks -B build/benchmarks
    cmake --build build/benchmarks -j${JOBS} --verbose


memcheck:
  valgrind --leak-check=full --track-origins=yes ./build/debug/examples/{{TARGET}}


coverage: test-cpp
    pushd ./build/debug/tests/_deps/octra-build/CMakeFiles/octra.dir/source/octra/ > /dev/null && \
    find . -type f -name '*.cpp.*' -exec bash -c 'for file in "$@"; do \
      new_file="${file/.cpp/}"; \
      if [ "$file" != "$new_file" ]; then \
        mv "$file" "$new_file"; \
      fi; \
    done' bash {} + && \
    popd > /dev/null
    mkdir -p build/gcov
    find ./build/debug/tests/_deps/octra-build/CMakeFiles/octra.dir/source/octra/ -type f -name "*.gcda" -exec cp {} ./build/gcov \;
    find ./build/debug/tests/_deps/octra-build/CMakeFiles/octra.dir/source/octra/ -type f -name "*.gcno" -exec cp {} ./build/gcov \;
    find ./source/ -type f -name "*.cpp" | while read -r src_file; do \
      filename=$(basename "$src_file"); \
      prefix="${filename%%.*}"; \
      if ls ./build/gcov/"${prefix}"*.gcda > /dev/null 2>&1; then \
        cp "$src_file" ./build/gcov; \
      fi; \
    done
    cp ./tests/source/main.cpp ./build/gcov
    # cp ./build/debug/tests/CMakeFiles/octraTests.dir/source/main* ./build/gcov
    # mv ./build/gcov/main.cpp.gcda ./build/gcov/main.gcda
    # mv ./build/gcov/main.cpp.gcno ./build/gcov/main.gcno
    mv ./build/gcov/main.cpp ./build/gcov/main.ol
    pushd build/gcov > /dev/null && \
      gcov -b -o . *.cpp && \
      lcov -c --ignore mismatch --directory . --output-file main_coverage.info && \
      lcov --ignore-errors inconsistent --ignore-errors unused -r main_coverage.info "Core/" --output-file main_coverage.info && \
      lcov --ignore-errors inconsistent --ignore-errors unused -r main_coverage.info "include/" --output-file main_coverage.info && \
      lcov --ignore-errors inconsistent --ignore-errors unused -r main_coverage.info "doctest/" --output-file main_coverage.info && \
      genhtml --ignore-errors inconsistent  --ignore-errors corrupt main_coverage.info --output-directory .



debuggable:
  nix-shell --run 'clang++ -g -O0 debug.cpp -o debug $(pkg-config --cflags octra) $(pkg-config --libs-only-L octra) $(pkg-config --cflags libxml-2.0) $(pkg-config --libs-only-L libxml-2.0) -std=c++20 -loctra -lxml2 '


clean:
    rm -rf build/
    rm -rf bindings/octrapy/build/
    rm -rf octradotnet/bin
    rm -rf octradotnet/obj
    rm -rf joctra-octra/build/
    rm -rf joctra/build/


# }}} utilities

# {{{ docs commands

docs: build
    @echo "Building docs"
    nix develop .#cpp --command bash -c "cmake -S docs -B build/debug/docs"
    nix develop .#cpp --command bash -c "cmake --build build/debug/docs --target GenerateDocs"

# }}} docs commands

# {{{ example commands

examples:
    @echo "Building Examples"
    nix develop .#cpp --command bash -c "cmake -S examples/cpp -B build/debug/examples --preset=debug -DCMAKE_MAKE_PROGRAM=$(which make) -DBUILD_W_INSTALLED=OFF"
    nix develop .#cpp --command bash -c "cmake --build build/debug/examples -j{{ JOBS }} --verbose"
    nix develop .#cpp --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
    # nix develop . --command bash -c "make -C ./build/debug/examples -j10 --verbose"

example EXAMPLE:
    @echo "Running Example {{ EXAMPLE }}:"
    ./build/debug/examples/{{ EXAMPLE }}

example-python:
    nix develop .#python --command bash -c "python examples/python/octra_ex.py"

# }}} example commands

# {{{ view commands

view-flamechart:
    $(BROWSER) ./flamegraph.svg

view-docs:
    @echo "Opening docs"
    qutebrowser ./build/debug/docs/doxygen/html/index.html

# }}} view commands

# {{{ windows specifics

windows-run: build
    @echo "Running target ${TARGET}"
    build/debug/examples/${TARGET}

# }}} windows specifics

# {{{ all commands

all-test: test-cpp test-python test-r test-javascript test-csharp test-java test-php

# }}} all commands
