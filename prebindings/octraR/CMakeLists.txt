if(NOT BUILD_R)
  return()
endif()

message("Building R library...")

cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()

project(octrar VERSION 0.1)

message("Copy over source files")
file(COPY ${PROJECT_SOURCE_DIR}/../../source/octra
     DESTINATION ${PROJECT_BINARY_DIR}/src)
file(COPY ${PROJECT_SOURCE_DIR}/../../include/octra
     DESTINATION ${PROJECT_BINARY_DIR}/src)

message("Copy over swig files")
file(COPY ${PROJECT_SOURCE_DIR}/swig_src/octrar.i
     DESTINATION ${PROJECT_BINARY_DIR}/src)

# Gather source files
file(GLOB_RECURSE C_HEADERS "${PROJECT_BINARY_DIR}/*.h")
file(GLOB_RECURSE CXX_HEADERS "${PROJECT_BINARY_DIR}/*.hpp")
file(GLOB_RECURSE C_SOURCES "${PROJECT_BINARY_DIR}/*.c")
file(GLOB_RECURSE CXX_SOURCES "${PROJECT_BINARY_DIR}/*.cpp")
set(OCTRA_SOURCES ${C_HEADERS} ${CXX_HEADERS} ${C_SOURCES} ${CXX_SOURCES})

# Copy source files into working directory and transform includes from system to local includes
foreach(filepath ${OCTRA_SOURCES})
  file(READ ${filepath} input_content)
  string(REGEX REPLACE "#include<octra/([^>]*)>" "#include \"octra/\\1\"" output_content "${input_content}")
  string(REGEX REPLACE "#include <octra/([^>]*)>" "#include \"octra/\\1\"" output_content "${input_content}")
  file(WRITE ${filepath} "${output_content}")
endforeach()

message("Building SWIG interface..")
execute_process(COMMAND swig -c++ -r -o ${PROJECT_BINARY_DIR}/src/octra_wrap.cpp ${PROJECT_BINARY_DIR}/src/octrar.i 
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
message("Done building SWIG interface...")


file(GLOB_RECURSE C_SOURCES "${PROJECT_SOURCE_DIR}/../../source/octra/*.c")
set(QUOTED_C_SOURCES "")
set(QUOTED_C_OBJECTS "")
foreach(filepath ${C_SOURCES})
  string(REPLACE 
    "${PROJECT_SOURCE_DIR}/../../source/octra/" 
    "octra/" 
    relative_filepath ${filepath})
  string(REPLACE ".c" ".o" relative_object ${relative_filepath})
  set(QUOTED_C_SOURCES "${QUOTED_C_SOURCES} ${relative_filepath}")
  set(QUOTED_C_OBJECTS "${QUOTED_C_OBJECTS} ${relative_object}")
endforeach()

file(GLOB_RECURSE CXX_SOURCES "${PROJECT_SOURCE_DIR}/../../source/octra/*.cpp")
set(QUOTED_CXX_SOURCES "")
set(QUOTED_CXX_OBJECTS "")
foreach(filepath ${CXX_SOURCES})
    string(REPLACE 
      "${PROJECT_SOURCE_DIR}/../../source/octra/" 
      "octra/" 
      relative_filepath ${filepath})
    string(REPLACE ".cpp" ".o" relative_object ${relative_filepath})
    set(QUOTED_CXX_SOURCES "${QUOTED_CXX_SOURCES} ${relative_filepath}")
    set(QUOTED_CXX_OBJECTS "${QUOTED_CXX_OBJECTS} ${relative_object}")
endforeach()
message("QUOTED_C_SOURCES: ${QUOTED_C_SOURCES}")
message("QUOTED_CXX_SOURCES: ${QUOTED_CXX_SOURCES}")

message("QUOTED_C_OBJECTS: ${QUOTED_C_OBJECTS}")
message("QUOTED_CXX_OBJECTS: ${QUOTED_CXX_OBJECTS}")

configure_file(${PROJECT_SOURCE_DIR}/Makevars.in
  ${PROJECT_BINARY_DIR}/src/Makevars @ONLY)

# Now copy into the R package
file(
  GENERATE
  OUTPUT ${PROJECT_BINARY_DIR}/src/Makevars
  INPUT ${PROJECT_SOURCE_DIR}/Makevars.in)

# Copy over octra
file(COPY ${PROJECT_BINARY_DIR}/src/octra DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/octraR/src/)

# Copy over octra wrappers
file(COPY ${PROJECT_BINARY_DIR}/src/octra_wrap.cpp DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/octraR/src/)

# Copy over R bindings
file(COPY ${PROJECT_BINARY_DIR}/src/octrar.R DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/octraR/R/)

