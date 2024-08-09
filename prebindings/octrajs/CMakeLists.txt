if(NOT BUILD_JAVASCRIPT)
  return()
endif()

message("Building Javascript library...")

cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()

project(octrajs
  VERSION 0.1)

file(GLOB_RECURSE CPP_SOURCES "${PROJECT_SOURCE_DIR}/../include/octra/*.hpp")

set(QUOTED_CPP_SOURCES "")
foreach(filepath ${CPP_SOURCES})
    string(REPLACE "${PROJECT_SOURCE_DIR}/../include/octra/" "octra/" relative_filepath ${filepath})
    set(QUOTED_CPP_SOURCES "${QUOTED_CPP_SOURCES}'${relative_filepath}', ")
endforeach()


configure_file(${PROJECT_SOURCE_DIR}/binding.gyp.in
               ${PROJECT_BINARY_DIR}/binding.gyp.in @ONLY)

file(
  GENERATE
  OUTPUT ${PROJECT_BINARY_DIR}/octrajs/binding.gyp
  INPUT ${PROJECT_BINARY_DIR}/binding.gyp.in)

file(COPY ${PROJECT_SOURCE_DIR}/src
     DESTINATION ${PROJECT_BINARY_DIR}/swig_src)

file(COPY ${PROJECT_SOURCE_DIR}/../../include/octra
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/octrajs/octra/octra_wrap.cxx
    COMMAND swig -javascript -node -c++ -o ${PROJECT_BINARY_DIR}/octrajs/octra/octra_wrap.cxx ../../swig_src/src/octra.i
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/octrajs/octra
)

file(COPY ${PROJECT_SOURCE_DIR}/package.json
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs/)


file(COPY ${PROJECT_SOURCE_DIR}/lib
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs)

# file(COPY ${PROJECT_SOURCE_DIR}/../javascript/tsconfig.json
#      DESTINATION ${PROJECT_BINARY_DIR}/examplejs/tsconfig.json)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/octrajs/build/Release/octra.node
    COMMAND node-gyp configure build
    DEPENDS ${PROJECT_BINARY_DIR}/octrajs/octra/octra_wrap.cxx
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/octrajs
)

add_custom_target(
    PrintHello ALL
    DEPENDS ${PROJECT_BINARY_DIR}/octrajs/build/Release/octra.node
    COMMAND echo "Hello, World!"
    COMMENT "Running custom command"
    VERBATIM
)
