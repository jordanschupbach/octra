if(NOT BUILD_PYTHON)
  return()
endif()

message("Building Python library...")

cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()

project(pyoctra VERSION 0.1)

# Copy source files into working directory
file(COPY ${PROJECT_SOURCE_DIR}/../../include/octra DESTINATION ${PROJECT_BINARY_DIR}/)
file(COPY ${PROJECT_SOURCE_DIR}/../../source/octra DESTINATION ${PROJECT_BINARY_DIR}/)

# Gather source files
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

# Copy SWIG interface file into working directory
file(COPY ${PROJECT_SOURCE_DIR}/swig_src DESTINATION ${PROJECT_BINARY_DIR}/)

# Build SWIG interface
message("Building SWIG interface...")
execute_process(COMMAND swig -c++ -python -o ${PROJECT_BINARY_DIR}/swig_src/octra_wrap.cpp ${PROJECT_BINARY_DIR}/swig_src/pyoctra.i 
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
message("Done building SWIG interface...")

file(GLOB_RECURSE C_SOURCES "${PROJECT_SOURCE_DIR}/../../source/octra/*.c")
set(QUOTED_C_SOURCES "")
foreach(filepath ${C_SOURCES})
string(REPLACE "${PROJECT_SOURCE_DIR}/../../source/octra/" "octrajs/octra/" relative_filepath ${filepath})
    set(QUOTED_C_SOURCES "${QUOTED_C_SOURCES}'${relative_filepath}', ")
endforeach()

file(GLOB_RECURSE CXX_SOURCES "${PROJECT_SOURCE_DIR}/../../source/octra/*.cpp")
set(QUOTED_CXX_SOURCES "")
foreach(filepath ${CXX_SOURCES})
message("${filepath}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/../../source/octra/" "octrajs/octra/" relative_filepath ${filepath})
    set(QUOTED_CXX_SOURCES "${QUOTED_CXX_SOURCES}'${relative_filepath}', ")
endforeach()

message("QUOTED_C_SOURCES: ${QUOTED_C_SOURCES}")
message("QUOTED_CXX_SOURCES: ${QUOTED_CXX_SOURCES}")


configure_file(${PROJECT_SOURCE_DIR}/pyproject.toml.in
               ${PROJECT_BINARY_DIR}/pyproject.toml.in @ONLY)

# Now copy into the Python package
file(
  GENERATE
  OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/pyproject.toml
  INPUT ${PROJECT_BINARY_DIR}/pyproject.toml.in)

file(COPY ${PROJECT_BINARY_DIR}/octra/ DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/pyoctra/pyoctra/octra)

file(COPY ${PROJECT_BINARY_DIR}/swig_src/octra_wrap.cpp DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/pyoctra/pyoctra/octra)
file(COPY ${PROJECT_BINARY_DIR}/swig_src/octra.py DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/pyoctra/pyoctra)
