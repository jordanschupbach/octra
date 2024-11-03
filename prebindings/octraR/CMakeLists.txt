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

# Now copy into the Python package
file(
  GENERATE
  OUTPUT ${PROJECT_BINARY_DIR}/src/Makevars
  INPUT ${PROJECT_SOURCE_DIR}/Makevars.in)


configure_file(${PROJECT_SOURCE_DIR}/Makevars.in
  ${PROJECT_BINARY_DIR}/Makevars.in @ONLY)

# Now copy into the Python package
file(
  GENERATE
  OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/Makevars
  INPUT ${PROJECT_BINARY_DIR}/Makevars.in)



# add_custom_command(
#     OUTPUT ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
#     COMMAND swig -r -c++ -o ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp ${PROJECT_BINARY_DIR}/src/octrar.i
#     WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
# )
# add_custom_target(
#   BuildSwig ALL
#   DEPENDS ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
#   COMMAND echo "Building OctraR swig bindings.."
#   COMMENT "Building OctraR swig bindings.."
#   VERBATIM
# )


# Copy over octra
file(COPY ${PROJECT_BINARY_DIR}/src/octra DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/octraR/src/)

# Copy over octra wrappers
file(COPY ${PROJECT_BINARY_DIR}/src/octra_wrap.cpp DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/octraR/src/)

# Copy over R bindings
file(COPY ${PROJECT_BINARY_DIR}/src/octrar.R DESTINATION ${PROJECT_BINARY_DIR}/../../bindings/octraR/R/)










# add_custom_command(
#     OUTPUT ${PROJECT_BINARY_DIR}/src/octrar.so
#     COMMAND swig -r -c++ -o ${PROJECT_BINARY_DIR}/src/octrar_wrap.cxx ${PROJECT_SOURCE_DIR}/swig/octrar.i
#     WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
# )

# 	R CMD SHLIB ./src/templater3_wrap.cpp ./src/circle.cpp
# 	R CMD SHLIB -o ./src/templater3.so ./src/templater3_wrap.cpp ./src/circle.cpp
# 	R CMD build .

# add_custom_command(
#     OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp
#     COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/
#     DEPENDS ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
# )
# 
# 
# add_custom_command(
#     OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar.R
#     COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/src/octrar.R ${PROJECT_SOURCE_DIR}/../../bindings/octraR/R/
#     DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp
# )
# 
# add_custom_target(copy_octraR_files
#     DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar.R
# )
# 
# add_custom_target(
#     CopyWrap ALL
#     DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar.R
#     COMMAND echo "Building OctraR finished!"
#     COMMENT "Running custom command"
#     VERBATIM
# )




# file(COPY ${PROJECT_SOURCE_DIR}/swig
#      DESTINATION ${PROJECT_BINARY_DIR}/octraR/swig)

# copy over octrar_wrap.cxx
# copy over octrar.r

# SAVE: just to inject into R build system at somepoint?

# file(GLOB_RECURSE CPP_HEADERS "${PROJECT_SOURCE_DIR}/../../include/octra/*.hpp")
# set(QUOTED_CPP_HEADERS "")
# foreach(filepath ${CPP_HEADERS})
# message("${filepath}")
#     string(REPLACE "${PROJECT_SOURCE_DIR}/../../include/octra/" "pyoctra/octra/" relative_filepath ${filepath})
#   set(QUOTED_CPP_HEADERS "${QUOTED_CPP_HEADERS}\"${relative_filepath}\", ")
# endforeach()
# message("CPP_HEADERS: ${QUOTED_CPP_HEADERS}")
#
# file(GLOB_RECURSE C_HEADERS "${PROJECT_SOURCE_DIR}/../../include/octra/*.h")
# set(QUOTED_C_HEADERS "")
# foreach(filepath ${C_SOURCES})
# message("${filepath}")
#     string(REPLACE "${PROJECT_SOURCE_DIR}/../../include/octra/" "octra/" relative_filepath ${filepath})
#   set(QUOTED_C_HEADERS "${QUOTED_CPP_HEADERS}'${relative_filepath}', ")
# endforeach()
# message("C_HEADERS: ${QUOTED_C_HEADERS}")


# file(
#   GENERATE
#   OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/setup.py
#   INPUT ${PROJECT_BINARY_DIR}/setup.py.in)

# file(COPY ${PROJECT_SOURCE_DIR}/swig_src
#      DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/pyoctra)


# add_custom_target(
#     RunCustomCommand ALL
#     DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/setup.py
#     COMMAND echo "Hello, World!"
#     COMMENT "Running custom command"
#     VERBATIM
# )
#



# add_custom_target(
#     FinishOctraR ALL
#     DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp
#     COMMAND echo "Building OctraR finished!"
#     COMMENT "Running custom command"
#     VERBATIM
# )






# message("Copying swig src")
# file(COPY ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
#      DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/)

