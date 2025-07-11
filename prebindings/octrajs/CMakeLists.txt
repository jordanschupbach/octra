# if(NOT BUILD_JAVASCRIPT)
#   return()
# endif()

message("Building Javascript library...")


cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()


# octra JavaScript bindings
project(octrajs
  VERSION 0.1)


# Copy source files into working directory
file(COPY ${PROJECT_SOURCE_DIR}/../../include/octra 
  DESTINATION ${PROJECT_BINARY_DIR}/octrajs/src/)
file(COPY ${PROJECT_SOURCE_DIR}/../../source/octra 
  DESTINATION ${PROJECT_BINARY_DIR}/octrajs/src/)


# Grab headers to put into binding.gyp
file(GLOB_RECURSE C_HEADERS "${PROJECT_BINARY_DIR}/*.h")
file(GLOB_RECURSE CXX_HEADERS "${PROJECT_BINARY_DIR}/*.hpp")
file(GLOB_RECURSE C_SOURCES "${PROJECT_BINARY_DIR}/*.c")
file(GLOB_RECURSE CXX_SOURCES "${PROJECT_BINARY_DIR}/*.cpp")
set(octra_SOURCES ${C_HEADERS} ${CXX_HEADERS} ${C_SOURCES} ${CXX_SOURCES})


# NOTE: I don't think this is necessary for octrajs
# Copy source files into working directory and transform includes from system to local
foreach(filepath ${octra_SOURCES})
  file(READ ${filepath} input_content)
  string(REGEX REPLACE "#include<octra/([^>]*)>" "#include \"octra/\\1\"" output_content "${input_content}")
  string(REGEX REPLACE "#include <octra/([^>]*)>" "#include \"octra/\\1\"" output_content "${input_content}")
  file(WRITE ${filepath} "${output_content}")
endforeach()


file(GLOB_RECURSE C_SOURCES "${PROJECT_SOURCE_DIR}/../../source/octra/*.c")
set(QUOTED_C_SOURCES "")
foreach(filepath ${C_SOURCES})
  string(REPLACE "${PROJECT_SOURCE_DIR}/../../source/octra/" "src/octra/" relative_filepath ${filepath})
  set(QUOTED_C_SOURCES "${QUOTED_C_SOURCES}'${relative_filepath}', ")
endforeach()


file(GLOB_RECURSE CXX_SOURCES "${PROJECT_SOURCE_DIR}/../../source/octra/*.cpp")
set(QUOTED_CXX_SOURCES "")
foreach(filepath ${CXX_SOURCES})
message("${filepath}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/../../source/octra/" "src/octra/" relative_filepath ${filepath})
    set(QUOTED_CXX_SOURCES "${QUOTED_CXX_SOURCES}'${relative_filepath}', ")
endforeach()


# configure_file(${PROJECT_SOURCE_DIR}/binding.gyp.in
#                ${PROJECT_BINARY_DIR}/binding.gyp.in @ONLY)


configure_file(${PROJECT_SOURCE_DIR}/setup.js.in
               ${PROJECT_BINARY_DIR}/setup.js.in @ONLY)


# file(
#   GENERATE
#   OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octrajs/binding.gyp
#   INPUT ${PROJECT_BINARY_DIR}/binding.gyp.in)

file(
  GENERATE
  OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octrajs/setup.js
  INPUT ${PROJECT_BINARY_DIR}/setup.js.in)


file(COPY ${PROJECT_SOURCE_DIR}/package.json
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs/)


file(COPY ${PROJECT_SOURCE_DIR}/src
     DESTINATION ${PROJECT_BINARY_DIR}/swig_src)

message("Building javascript SWIG bindings...")

execute_process( # was node (not jsc)
  COMMAND swig -javascript -typescript -napi -c++ -o ${PROJECT_BINARY_DIR}/octrajs/src/octra/octra_wrap.cxx ../../swig_src/src/octrajs.i
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/octrajs/src)

message("Done building javascript SWIG bindings...?")

file(COPY ${PROJECT_SOURCE_DIR}/lib/index.js
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs/src/)


file(COPY ${PROJECT_BINARY_DIR}/octrajs/
  DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/octrajs/)


 # add_custom_target(
 #     PrintHello ALL
 #     DEPENDS ${PROJECT_BINARY_DIR}/octrajs/octrajs/binding.gyp
 #     COMMAND echo "Building JavaScript library!"
 #     COMMENT "Running custom command"
 #     VERBATIM
 # )


