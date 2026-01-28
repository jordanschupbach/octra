TARGET := "StlEx"
BENCH_TARGET := ""
JOBS := "20"

run: run-cpp

run-csharp: csharp-build
  nix develop .#csharp --command bash -c "dotnet run --project ./octradotnet"

run-java: java-build
  nix develop .#java --command bash -c "gradle run --no-configuration-cache --args='{{ TARGET }}'"

run-python:
  nix develop .#python --command bash -c 'python examples/python/{{ TARGET }}.py'

run-php: php-build
  nix develop .#php --command bash -c 'php --php-ini .user.ini examples/php/octra_ex.php'

run-r: prebuild-r
  nix develop .#r --command bash -c 'Rscript examples/r/octra_ex.r'

run-javascript: javascript-build
  nix develop .#javascript --command bash -c 'node ./examples/javascript/octra_ex.js'



# NOTE: these prebuilds should be done using CMAKE at some point

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
php-prebuild:
  cd ./include && swig -c++ -php7 -o ../src/octra_php_wrap.cpp ../prebindings/octraPHP/src/octraPHP.i
  # nix develop .#php --command bash -c 'g++ `php-config --includes` -fpic -c ../source/octra/octra.cpp ../src/octra_php_wrap.cpp'


# NOTE: compiles (doesnt work?)
# build-php: prebuild-php
#   nix develop .#php --command bash -c 'cmake -S prebindings/octraPHP -B build/octraPHP'
#   nix develop .#php --command bash -c 'cmake --build build/octraPHP'


php-build: php-prebuild
  nix develop .#php --command bash -c 'cmake -S prebindings/octraPHP -B build/octraPHP'
  nix develop .#php --command bash -c 'cmake --build build/octraPHP -j{{ JOBS }} --verbose'

#   mkdir -p ./build/octraPHP
#   nix develop .#php --command bash -c 'g++ `php-config --includes` -fpic -c source/octra/octra.cpp -o ./build/octraPHP/octra.o -I./include && g++ `php-config --includes` -fpic -c src/octra_php_wrap.cpp -o ./build/octraPHP/octra_php_wrap.o -I./include'
#   nix develop .#php --command bash -c 'g++ -shared ./build/octraPHP/octra.o  ./build/octraPHP/octra_php_wrap.o -o ./build/octraPHP/liboctraPHP.so `php-config --ldflags`'


javascript-repl: prebuild-javascript javascript-build
  nix develop .#javascript --command bash -c 'node'


python-test-build: prebuild-python
  nix develop .#python --command bash -c 'python setup.py sdist bdist_wheel'

python-repl: prebuild-python
  nix develop .#python --command bash -c 'ipython'

r-repl: prebuild-r
  nix develop .#r --command bash -c 'R'

php-repl: php-build
  nix develop .#php --command bash -c 'php -a --php-ini .user.ini'

# ./build/octraPHP/liboctraPHP.so ./build/octraPHP/octra.so
#nix develop .#r --command 'R'

csharp-repl: csharp-build
  nix develop .#csharp --command bash -c "dotnet tool install dotnet-csi && dotnet csi"

java-repl:
  nix develop .#java --command bash -c 'export LD_LIBRARY_PATH=jOCTRA/build/libs:$LD_LIBRARY_PATH && jshell --class-path ./jOCTRA/build/libs/jOCTRA.jar'

csharp-build: prebuild-csharp
  nix develop .#csharp --command bash -c "cmake -S ./octradotnet -B build/dotnet/release -DCMAKE_MAKE_PROGRAM=$(which make)"
  nix develop .#csharp --command bash -c "cmake --build build/dotnet/release -j{{ JOBS }} --verbose"
  nix develop .#csharp --command bash -c "cd ./octradotnet && dotnet build"
  cp build/dotnet/release/liboctradotnet.so ./octradotnet/bin/Debug/net10.0/liboctra.so

csharp-run: csharp-build
  nix develop .#csharp --command bash -c "dotnet run --project ./octradotnet"


cpp-repl:
  nix develop .#cpp --command bash -c 'cling $(pkg-config --cflags octra) $(pkg-config --libs-only-L octra) -loctra -std=c++17'


jq:
    nix develop . --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"


add:
  git add .



benchmark:
    @echo "Building Examples"
    cmake -S benchmarks -B build/benchmarks
    cmake --build build/benchmarks -j${JOBS} --verbose


memcheck:
  valgrind --leak-check=full --track-origins=yes ./build/debug/examples/{{TARGET}}

# python
bindings: 
  echo "Building Bindings"

build: build-debug

build-release:
  nix develop .#cpp --command bash -c "cmake -S . -B build/release --preset=release-clang-linux-x86 -DCMAKE_MAKE_PROGRAM=$(which make)"
  ln -sf build/release/compile_commands.json compile_commands.json

build-debug:
  nix develop .#cpp --command bash -c "cmake -S . -B build/debug --preset=debug-clang-linux-x86 -DCMAKE_MAKE_PROGRAM=$(which make)"
  ln -sf build/debug/compile_commands.json compile_commands.json

cpp-build:
    @echo "Building OCTRA"
    nix develop .#cpp --command bash -c "cmake -S . -B build"
    nix develop .#cpp --command bash -c "cmake --build build -j{{ JOBS }} --verbose"
    nix develop .#cpp --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"

clean:
    rm -rf build/
    rm -rf bindings/OCTRApy/build/
    rm -rf octradotnet/bin
    rm -rf octradotnet/obj
    rm -rf jOCTRA-octra/build/
    rm -rf jOCTRA/build/

clean-certs:
    rm -f server-cert.pem server-key.pem ca-cert.pem ca-key.pem server-csr.pem

# TODO: move this as a script somewhere
coverage: test
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

# lcov -r main_coverage.info "playground/" --output-file main_coverage.info && \
# lcov -r main_coverage.info "/usr*" --output-file main_coverage.info && \
# lcov -r main_coverage.info "doctest/doctest.h" --output-file main_coverage.info && \
# lcov -r main_coverage.info "include/octra/extern/" --output-file main_coverage.info && \
#     rm ./build/gcov/octra.cpp
#     rm ./build/gcov/octra.gcda
#     rm ./build/gcov/octra.gcno

cpp: test examples

create-certificate:
    # Create for server
    openssl req -new -x509 -days 365 -nodes -out server-cert.pem -keyout server-key.pem
    # Create for client
    openssl genrsa -out ca.key 2048
    openssl req -x509 -new -nodes -key ca.key -sha256 -days 1024 -out ca.crt

dev:
    nix develop .

docs: build
    @echo "Building docs"
    nix develop .#cpp --command bash -c "cmake -S docs -B build/debug/docs"
    nix develop .#cpp --command bash -c "cmake --build build/debug/docs --target GenerateDocs"

flamechart:
    @echo "Running Performance Tests"
    @perf record -F 99 -g ./build/examples/${TARGET}
    @perf script > out.perf
    @if [ ! -d "Flamegraph" ]; then \
    	git clone https://github.com/brendangregg/Flamegraph.git; \
    fi
    @./Flamegraph/stackcollapse-perf.pl out.perf > out.folded
    @./Flamegraph/flamegraph.pl out.folded > flamegraph.svg

# TODO: uncomment when implemented
# format:
#     @echo "Formatting code"
#     cmake --build build --target fix-format

gen-certs:
    @echo "Step 1: Create a Certificate Authority (CA)"
    @echo "Generate a CA private key:"
    @openssl genpkey -algorithm RSA -out ca-key.pem -pkeyopt rsa_keygen_bits:2048
    @echo "Create a CA certificate"
    @openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 365 -out ca-cert.pem
    @echo "Step 2: Generate a Server Certificate and Key"
    @echo "Generate a server private key"
    @openssl genpkey -algorithm RSA -out server-key.pem -pkeyopt rsa_keygen_bits:2048
    @echo "Create a certificate signing request (CSR) for the server"
    @openssl req -new -key server-key.pem -out server-csr.pem
    @echo "Sign the server certificate with the CA" 
    @openssl x509 -req -in server-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 365 -sha256
    @echo "Step 3: Generate a Client Certificate and Key (Optional)"
    @echo "Generate client private key"
    @openssl genpkey -algorithm RSA -out client-key.pem -pkeyopt rsa_keygen_bits:2048
    @echo "Create a certificate signing request (CSR) for the client"
    @openssl req -new -key client-key.pem -out client-csr.pem
    @echo "Sign the client certificate with your CA"
    @openssl x509 -req -in client-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 365 -sha256

jsdev:
    nix develop . --command bash -c "cmake -S prebindings/OCTRAjs -B build/OCTRAjs"
    nix develop ./bindings/OCTRAjs/ --command bash -c "npm --prefix ./bindings/OCTRAjs/ install"
    nix develop ./bindings/OCTRAjs/ --command bash -c "npm --prefix ./bindings/OCTRAjs/ run build"
    nix develop ./bindings/OCTRAjs/

# js-cpp-build:
#     rm -f ./bindings/OCTRAjs/binding.gyp # TODO: call make clean from OCTRAjs
#     nix develop . --command bash -c "cmake -S prebindings/OCTRAjs -B build/OCTRAjs"
#     nix develop . --command bash -c "cmake --build build/OCTRAjs"

javascript-build: prebuild-javascript
    nix develop .#jsbuild --command bash -c "npm --prefix . run build"


js-test:
    @echo "Running JavaScript Tests"
    nix develop ./bindings/OCTRAjs/ --command bash -c "npm --prefix ./bindings/OCTRAjs/ run test"

linux-run: examples
    @echo "Running target ${TARGET}"
    ./build/debug/examples/${TARGET}

examples:
    @echo "Building Examples"
    nix develop .#cpp --command bash -c "cmake -S examples/cpp -B build/debug/examples --preset=debug -DCMAKE_MAKE_PROGRAM=$(which make) -DBUILD_W_INSTALLED=OFF"
    nix develop .#cpp --command bash -c "cmake --build build/debug/examples -j{{ JOBS }} --verbose"
    nix develop .#cpp --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
    # nix develop . --command bash -c "make -C ./build/debug/examples -j10 --verbose"

example EXAMPLE:
    @echo "Running Example {{ EXAMPLE }}:"
    ./build/debug/examples/{{ EXAMPLE }}


prebuild-java:
  find jOCTRA/src/main/java/js/octra/joctra -type f -name '*.java' ! -name 'App.java' ! -path 'jOCTRA/src/main/java/js/octra/joctra/examples/*' -exec rm {} +
  cd ./include && swig -c++ -java -o ../jOCTRA-octra/octra_java_wrap.cpp -package js.octra.joctra -outdir ../jOCTRA/src/main/java/js/octra/joctra ../prebindings/joctra/src/joctra.i # && mv ../src/octrar.R ../R


java-build: prebuild-java
  nix develop .#java --command bash -c "gradle cmakeBuild"
  mkdir -p jOCTRA/build/libs
  cp jOCTRA-octra/build/cmake/libjOCTRA.so jOCTRA/build/libs/liboctra.so
  nix develop .#java --command bash -c "gradle build"

play:
  nix develop .#java --command bash -c "echo \$CMAKE_PATH"

test-javascript: javascript-build
    @echo "Running Javascript Tests"
    nix develop .#javascript --command bash -c "npm run test"


#  nix develop .#java --command bash -c "cmake -S ./jOCTRA -B build/jOCTRA -DCMAKE_MAKE_PROGRAM=$(which make)"
#  nix develop .#java --command bash -c "cmake --build build/jOCTRA -j{{ JOBS }} --verbose"

#  cd ./include && swig -c++ -java -o ../src/octra_jOCTRA_wrap.cpp ../prebindings/jOCTRA/src/jOCTRA.i
#   cd ./include && swig -c++ -java -package js.octra.octra -outdir ./bindings/jOCTRA/src/main/java/octra/bindings/jOCTRA -o ../src/octra_jOCTRA_wrap.cpp ../prebindings/jOCTRA/src/jOCTRA.i

# java-build:
#     nix develop ./bindings/jOCTRA/ --command bash -c "just --justfile ./bindings/jOCTRA/justfile cmake"
#     nix develop ./bindings/jOCTRA/ --command bash -c "just --justfile ./bindings/jOCTRA/justfile build"


dotnet-build:
    nix develop . --command bash -c "cmake -S prebindings/octradotnet -B build/octradotnet"
    nix develop . --command bash -c "cmake --build build/octradotnet"
    # nix develop ./bindings/OCTRADotNet/ --command bash -c "just --justfile ./bindings/OCTRADotNet/justfile build"


playground:
    @echo "Building playground"
    nix develop .#cpp --command bash -c "cmake -S playground -B build/debug/playground"
    nix develop .#cpp --command bash -c "cmake --build build/debug/playground -j {{JOBS}} --verbose"
    ./build/debug/playground/playground_cpp

pydev:
    nix develop . --command bash -c "cmake -S prebindings/OCTRApy -B build/OCTRApy"
    nix develop ./bindings/OCTRApy/ --command bash -c "sudo pip install ./bindings/OCTRApy/"
    nix develop ./bindings/OCTRApy/

# TODO: remove pip install from this
# python:
#     nix develop . --command bash -c "cmake -S prebindings/OCTRApy -B build/OCTRApy"
#     nix develop ./bindings/OCTRApy/ --command bash -c "sudo pip install --user ./bindings/OCTRApy/"
#     nix develop ./bindings/OCTRApy/ --command bash -c "python ./bindings/OCTRApy/examples/hello_world_ex.py"

python-example:
    python ./bindings/OCTRApy/examples/hello_world_ex.py


build-example-installed:
  nix-shell --run 'cmake -S examples -B build/debug/examples --preset=debug -DCMAKE_MAKE_PROGRAM=$(which make) -DBUILD_W_INSTALLED=ON'

debuggable:
  nix-shell --run 'clang++ -g -O0 debug.cpp -o debug $(pkg-config --cflags octra) $(pkg-config --libs-only-L octra) $(pkg-config --cflags libxml-2.0) $(pkg-config --libs-only-L libxml-2.0) -std=c++20 -loctra -lxml2 '

open-clion:
  nix-shell --run 'clion &'



run-cpp: examples
    @echo "Running target {{ TARGET }}"
    ./build/debug/examples/{{ TARGET }}

run-benchmark:
    @echo "Running Benchmarks"
    ./build/benchmarks/${BENCH_TARGET}

run-server:
    @echo "Running server on port 8080"
    # ./build/debug/examples/server_run_ex_cpp 6 8080
    ./build/debug/examples/reasoner_server_ex_cpp 6 8080 127.0.0.1

run-client-test:
    @echo "Running client test on port 8080"
    ./build/debug/examples/aiestate_client_ex_cpp


test: test-cpp test-javascript

test-cpp:
    @echo "Running Tests"
    nix develop .#cpp --command bash -c "cmake -S tests -B build/debug/tests --preset=debug -DCMAKE_MAKE_PROGRAM=$(which make)"
    nix develop .#cpp --command bash -c "cmake --build build/debug/tests -j{{ JOBS }} --verbose"
    nix develop .#cpp --command bash -c "find ./build/ -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
    ./build/debug/tests/octraTests

view-flamechart:
    $(BROWSER) ./flamegraph.svg

view-docs:
    @echo "Opening docs"
    qutebrowser ./build/debug/docs/doxygen/html/index.html

windows-run: build
    @echo "Running target ${TARGET}"
    build/debug/examples/${TARGET}

# # TODO: deprecate this by finalizing js- bindings
# javascript:
#   rm -f ./bindings/OCTRAjs/binding.gyp # TODO: call make clean from OCTRAjs
#   nix develop . --command bash -c "cmake -S prebindings/OCTRAjs -B build/OCTRAjs"
#   nix develop . --command bash -c "cmake --build build/OCTRAjs"
#   # nix develop ./bindings/OCTRAjs/ --command bash -c "npm --prefix ./bindings/OCTRAjs/ install"
# nix develop ./bindings/OCTRAjs/ --command bash -c "npm --prefix ./bindings/OCTRAjs/ run build"
