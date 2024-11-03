if(NOT BUILD_R)
  return()
endif()

message("Building R library...")

cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()

project(octrar VERSION 0.1)

# message("Making octra directory")
# file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/octra)

message("Copy over source files")
file(COPY ${PROJECT_SOURCE_DIR}/../../src/octra
     DESTINATION ${PROJECT_BINARY_DIR}/src)

message("Copy over octrar.i")
file(COPY ${PROJECT_SOURCE_DIR}/swig/octrar.i
     DESTINATION ${PROJECT_BINARY_DIR}/src)

message("Copy over swig files")
file(COPY ${PROJECT_SOURCE_DIR}/swig
     DESTINATION ${PROJECT_BINARY_DIR}/swig)

# Copy ocra into src

# message("Copying octra into src")
# file(COPY ${PROJECT_SOURCE_DIR}/../../src/octra
#      DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src)


message("Building octrar_wrap")
add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
    COMMAND swig -r -c++ -o ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp ${PROJECT_BINARY_DIR}/src/octrar.i
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/src/octrar.so
    COMMAND swig -r -c++ -o ${PROJECT_BINARY_DIR}/src/octrar_wrap.cxx ${PROJECT_SOURCE_DIR}/swig/octrar.i
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)

# 	R CMD SHLIB ./src/templater3_wrap.cpp ./src/circle.cpp
# 	R CMD SHLIB -o ./src/templater3.so ./src/templater3_wrap.cpp ./src/circle.cpp
# 	R CMD build .

add_custom_command(
    OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp
    COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/
    DEPENDS ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
)


add_custom_command(
    OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar.R
    COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/src/octrar.R ${PROJECT_SOURCE_DIR}/../../bindings/octraR/R/
    DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp
)

add_custom_target(copy_octraR_files
    DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar.R
)

add_custom_target(
    CopyWrap ALL
    DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar.R
    COMMAND echo "Building OctraR finished!"
    COMMENT "Running custom command"
    VERBATIM
)




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

# configure_file(${PROJECT_SOURCE_DIR}/setup.py.in
#                ${PROJECT_BINARY_DIR}/setup.py.in @ONLY)

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



add_custom_target(
    FinishOctraR ALL
    DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/octrar_wrap.cpp
    COMMAND echo "Building OctraR finished!"
    COMMENT "Running custom command"
    VERBATIM
)






# message("Copying swig src")
# file(COPY ${PROJECT_BINARY_DIR}/src/octrar_wrap.cpp
#      DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/octraR/src/)

