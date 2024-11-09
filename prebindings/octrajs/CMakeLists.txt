if(NOT BUILD_JAVASCRIPT)
  return()
endif()

message("Building Javascript library...")

cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()

# Octra JavaScript bindings
project(octrajs
  VERSION 0.1)

# Copy source files into working directory
file(COPY ${PROJECT_SOURCE_DIR}/../../include/octra DESTINATION ${PROJECT_BINARY_DIR}/octrajs/src/)
file(COPY ${PROJECT_SOURCE_DIR}/../../source/octra DESTINATION ${PROJECT_BINARY_DIR}/octrajs/src/)

# Grab headers to put into binding.gyp
file(GLOB_RECURSE C_HEADERS "${PROJECT_BINARY_DIR}/*.h")
file(GLOB_RECURSE CXX_HEADERS "${PROJECT_BINARY_DIR}/*.hpp")
file(GLOB_RECURSE C_SOURCES "${PROJECT_BINARY_DIR}/*.c")
file(GLOB_RECURSE CXX_SOURCES "${PROJECT_BINARY_DIR}/*.cpp")
set(OCTRA_SOURCES ${C_HEADERS} ${CXX_HEADERS} ${C_SOURCES} ${CXX_SOURCES})

# Copy source files into working directory and transform includes from system to local
foreach(filepath ${OCTRA_SOURCES})
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


configure_file(${PROJECT_SOURCE_DIR}/binding.gyp.in
               ${PROJECT_BINARY_DIR}/binding.gyp.in @ONLY)

file(
  GENERATE
  OUTPUT ${PROJECT_BINARY_DIR}/octrajs/binding.gyp
  INPUT ${PROJECT_BINARY_DIR}/binding.gyp.in)


file(COPY ${PROJECT_SOURCE_DIR}/package.json
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs/)

file(COPY ${PROJECT_SOURCE_DIR}/src
     DESTINATION ${PROJECT_BINARY_DIR}/swig_src)


execute_process(
  COMMAND swig -javascript -node -c++ -o ${PROJECT_BINARY_DIR}/octrajs/src/octra/octra_wrap.cxx ../../swig_src/src/octra.i
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/octrajs/src)

file(COPY ${PROJECT_SOURCE_DIR}/lib/index.js
     DESTINATION ${PROJECT_BINARY_DIR}/octrajs/src/)

# file(COPY ${PROJECT_SOURCE_DIR}/package.json
#      DESTINATION ${PROJECT_BINARY_DIR}/octrajs/)
# 

# file(COPY ${PROJECT_SOURCE_DIR}/lib
#      DESTINATION ${PROJECT_BINARY_DIR}/octrajs)
# 

# # file(COPY ${PROJECT_SOURCE_DIR}/../javascript/tsconfig.json
# #      DESTINATION ${PROJECT_BINARY_DIR}/examplejs/tsconfig.json)
# 

# add_custom_command(
#     OUTPUT ${PROJECT_BINARY_DIR}/octrajs/build/Release/octra.node
#     COMMAND node-gyp configure build
#     DEPENDS ${PROJECT_BINARY_DIR}/octrajs/octra/octra_wrap.cxx
#     WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/octrajs
# )

# add_custom_target(
#     PrintHello ALL
#     DEPENDS ${PROJECT_BINARY_DIR}/octrajs/build/Release/octra.node
#     COMMAND echo "Hello, World!"
#     COMMENT "Running custom command"
#     VERBATIM
# )
