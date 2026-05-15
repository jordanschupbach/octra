TARGET := "octra_ex"
BENCH_TARGET := ""
JOBS := "20"

NIX_DEVELOP := "nix develop --accept-flake-config"

# {{{ run commands

run: run-cpp

run-csharp: build-csharp
  {{ NIX_DEVELOP }} .#csharp --command bash -lc "LD_LIBRARY_PATH=build/dotnet/release:$LD_LIBRARY_PATH dotnet run --project ./octradotnet"

run-java: build-java
  {{ NIX_DEVELOP }} .#java --command bash -lc "gradle run --no-configuration-cache --args='{{ TARGET }}'"

run-python:
  {{ NIX_DEVELOP }} .#python --command bash -lc 'python examples/python/{{ TARGET }}.py'

run-php: build-php
  {{ NIX_DEVELOP }} .#php --command bash -lc 'php --php-ini .user.ini examples/php/octra_ex.php'

run-r: prebuild-r
  {{ NIX_DEVELOP }} .#r --command bash -lc 'Rscript examples/r/octra_ex.r'

run-javascript: build-javascript
  {{ NIX_DEVELOP }} .#javascript --command bash -lc 'node ./examples/javascript/octra_ex.js'

run-cpp: examples
    @echo "Running target {{ TARGET }}"
    ./build/debug/examples/{{ TARGET }}

run-benchmark:
    @echo "Running Benchmarks"
    ./build/benchmarks/${BENCH_TARGET}


# }}} run commands

# {{{ prebuild commands

prebuild-python:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cd ./include && swig -c++ -python -o ../src/octra_python_wrap.cpp ../prebindings/pyoctra/src/pyoctra.i && mv ../src/octra.py ../src/pyoctra/octra.py"

prebuild-javascript:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cd ./include && swig -javascript -typescript -napi -c++ -o ../src/octra_js_wrap.cpp ../prebindings/octrajs/src/octrajs.i"

prebuild-csharp:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "find ./octradotnet -type f -name '*.cs' ! -name 'Program.cs' -exec rm {} +"
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cd ./include && swig -c++ -csharp -dllimport octra_csharp -o ../octradotnet/octra_csharp_wrap.cpp ../prebindings/octradotnet/src/octradotnet.i"
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "sed -i 's/DllImport(\"octra\"/DllImport(\"octra_csharp\"/g' ./octradotnet/octraPINVOKE.cs"

prebuild-r:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cd ./include && swig -c++ -r -o ../src/octra_r_wrap.cpp ../prebindings/octrar/src/octrar.i && mv ../src/octrar.R ../R"

# TODO:
prebuild-php:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cd ./include && swig -c++ -php7 -o ../src/octra_php_wrap.cpp ../prebindings/octraPHP/src/octraPHP.i"

prebuild-java:
  {{ NIX_DEVELOP }} .#java --command bash -lc "find joctra/src/main/java/js/octra/joctra -type f -name '*.java' ! -name 'App.java' ! -path 'joctra/src/main/java/js/octra/joctra/examples/*' -exec rm {} +"
  {{ NIX_DEVELOP }} .#java --command bash -lc "rm -rf joctra-octra/build/cmake"
  {{ NIX_DEVELOP }} .#java --command bash -lc "cd ./include && swig -c++ -java -o ../joctra-octra/octra_java_wrap.cpp -package js.octra.joctra -outdir ../joctra/src/main/java/js/octra/joctra ../prebindings/joctra/src/joctra.i"
  {{ NIX_DEVELOP }} .#java --command bash -lc "sed -i 's/System.loadLibrary(\"octra\")/System.loadLibrary(\"octra_jni\")/g' joctra/src/main/java/js/octra/joctra/App.java joctra/src/main/java/js/octra/joctra/examples/StlEx.java"
  {{ NIX_DEVELOP }} .#java --command bash -lc "perl -0777 -pi -e 's/public class octra \\{/public class octra {\\n  static { System.loadLibrary(\"octra_jni\"); }/s' joctra/src/main/java/js/octra/joctra/octra.java"

# }}} prebuild commands

# {{{ build commands

build-php: prebuild-php
  {{ NIX_DEVELOP }} .#php --command bash -lc 'cmake -S prebindings/octraPHP -B build/octraPHP'
  {{ NIX_DEVELOP }} .#php --command bash -lc 'cmake --build build/octraPHP -j{{ JOBS }} --verbose'


build: build-debug

build-example-installed:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc 'cmake -S examples/cpp -B build/debug/examples-installed -DCMAKE_BUILD_TYPE=Debug -DCMAKE_MAKE_PROGRAM=$(command -v make) -DBUILD_W_INSTALLED=ON'


build-release:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S . -B build/release --preset=release-clang-linux-x86 -DCMAKE_MAKE_PROGRAM=$(command -v make)"
  ln -sf build/release/compile_commands.json compile_commands.json

build-debug:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S . -B build/debug --preset=debug-clang-linux-x86 -DCMAKE_MAKE_PROGRAM=$(command -v make)"
  ln -sf build/debug/compile_commands.json compile_commands.json

build-cpp:
    @echo "Building octra"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S . -B build"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake --build build -j{{ JOBS }} --verbose"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"


build-csharp: prebuild-csharp
  {{ NIX_DEVELOP }} .#csharp --command bash -lc "cmake -S ./octradotnet -B build/dotnet/release -DCMAKE_MAKE_PROGRAM=$(command -v make)"
  {{ NIX_DEVELOP }} .#csharp --command bash -lc "cmake --build build/dotnet/release -j{{ JOBS }} --verbose"
  {{ NIX_DEVELOP }} .#csharp --command bash -lc "cd ./octradotnet && dotnet build"


build-javascript: prebuild-javascript
    {{ NIX_DEVELOP }} .#jsbuild --command bash -lc "npm --prefix . run build"


build-java: prebuild-java
  {{ NIX_DEVELOP }} .#java --command bash -lc "gradle cmakeBuild"
  {{ NIX_DEVELOP }} .#java --command bash -lc "gradle build"

build-dotnet:
    {{ NIX_DEVELOP }} . --command bash -lc "cmake -S prebindings/octradotnet -B build/octradotnet"
    {{ NIX_DEVELOP }} . --command bash -lc "cmake --build build/octradotnet"
    # nix develop ./bindings/octraDotNet/ --command bash -c "just --justfile ./bindings/octraDotNet/justfile build"


# }}} build commands

# {{{ repl commands

repl-javascript: prebuild-javascript build-javascript
  {{ NIX_DEVELOP }} .#javascript --command bash -lc 'node'

repl-python: prebuild-python
  {{ NIX_DEVELOP }} .#python --command bash -lc 'ipython'

repl-r: prebuild-r
  {{ NIX_DEVELOP }} .#r --command bash -lc 'R'

repl-php: build-php
  {{ NIX_DEVELOP }} .#php --command bash -lc 'php -a --php-ini .user.ini'

repl-csharp: build-csharp
  {{ NIX_DEVELOP }} .#csharp --command bash -lc "LD_LIBRARY_PATH=build/dotnet/release:$LD_LIBRARY_PATH if command -v dotnet-repl >/dev/null 2>&1; then dotnet-repl; elif command -v csi >/dev/null 2>&1; then csi; else echo 'No C# REPL found (expected dotnet-repl or csi)' >&2; exit 1; fi"

repl-java:
  {{ NIX_DEVELOP }} .#java --command bash -lc 'export LD_LIBRARY_PATH=joctra-octra/build/cmake:$LD_LIBRARY_PATH && jshell --class-path ./joctra/build/libs/joctra.jar'

repl-cpp:
  {{ NIX_DEVELOP }} .#cpp --command bash -lc 'cling $(pkg-config --cflags octra) $(pkg-config --libs-only-L octra) -loctra -std=c++17'

# }}} repl commands

# {{{ test commands

test-python-build: prebuild-python
  {{ NIX_DEVELOP }} .#python --command bash -lc 'python -m venv --system-site-packages build/venv/pyoctra-build'
  {{ NIX_DEVELOP }} .#python --command bash -lc 'build/venv/pyoctra-build/bin/python setup.py sdist bdist_wheel'

test-python: prebuild-python
  {{ NIX_DEVELOP }} .#python --command bash -lc 'python -m venv --system-site-packages build/venv/pyoctra'
  {{ NIX_DEVELOP }} .#python --command bash -lc 'build/venv/pyoctra/bin/python -m pip install -e . --no-build-isolation'
  {{ NIX_DEVELOP }} .#python --command bash -lc 'build/venv/pyoctra/bin/python -m pytest -q bindings_tests/python'

test-r: prebuild-r
  {{ NIX_DEVELOP }} .#r --command bash -lc 'R -q -e "testthat::test_local(\".\")"'

test-csharp: build-csharp
  {{ NIX_DEVELOP }} .#csharp --command bash -lc 'LD_LIBRARY_PATH=build/dotnet/release:$LD_LIBRARY_PATH dotnet test ./octradotnet.tests'

test-java: build-java
  {{ NIX_DEVELOP }} .#java --command bash -lc 'export LD_LIBRARY_PATH=joctra-octra/build/cmake:$LD_LIBRARY_PATH && gradle test'

test-php: build-php
  {{ NIX_DEVELOP }} .#php --command bash -lc 'php -d assert.exception=1 -d zend.assertions=1 --php-ini .user.ini bindings_tests/php/test_octra.php'


test-javascript: build-javascript
    @echo "Running Javascript Tests"
    {{ NIX_DEVELOP }} .#javascript --command bash -lc "npm run test"


test-cpp:
    @echo "Running Tests"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S tests -B build/debug/tests -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_MAKE_PROGRAM=$(command -v make)"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake --build build/debug/tests -j{{ JOBS }} --verbose"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "find ./build/ -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "ctest --test-dir build/debug/tests --output-on-failure"


# }}} test commands

# {{{ utilities

rename NEW:
  ./rename_octra {{ NEW }}

jq:
    {{ NIX_DEVELOP }} . --command bash -lc "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"


playground:
    @echo "Building playground"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S playground -B build/debug/playground"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake --build build/debug/playground -j {{JOBS}} --verbose"
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
  {{ NIX_DEVELOP }} .#cpp --command bash -lc 'clang++ -g -O0 debug.cpp -o debug $(pkg-config --cflags octra) $(pkg-config --libs-only-L octra) $(pkg-config --cflags libxml-2.0) $(pkg-config --libs-only-L libxml-2.0) -std=c++20 -loctra -lxml2'


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
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S docs -B build/debug/docs"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake --build build/debug/docs --target GenerateDocs"

# }}} docs commands

# {{{ example commands

examples:
    @echo "Building Examples"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake -S examples/cpp -B build/debug/examples --preset=debug -DCMAKE_MAKE_PROGRAM=$(command -v make) -DBUILD_W_INSTALLED=OFF"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "cmake --build build/debug/examples -j{{ JOBS }} --verbose"
    {{ NIX_DEVELOP }} .#cpp --command bash -lc "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
    # nix develop . --command bash -c "make -C ./build/debug/examples -j10 --verbose"

example EXAMPLE:
    @echo "Running Example {{ EXAMPLE }}:"
    ./build/debug/examples/{{ EXAMPLE }}

example-python:
    {{ NIX_DEVELOP }} .#python --command bash -lc "python examples/python/octra_ex.py"

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

test-nix:
  nix flake check --accept-flake-config -L

build-nix PACKAGE="octra":
  nix build --accept-flake-config ".#{{ PACKAGE }}"

update-java-deps:
  nix/update-joctra-gradle-deps.sh

update-csharp-deps:
  nix/update-nuget-deps.sh

all-test: test-cpp test-python test-r test-javascript test-csharp test-java test-php

# }}} all commands
