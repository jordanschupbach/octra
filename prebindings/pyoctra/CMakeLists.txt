if(NOT BUILD_PYTHON)
  return()
endif()

message("Building Python library...")

cmake_minimum_required(VERSION 3.18)
if(POLICY CMP0122)
  cmake_policy(SET CMP0122 NEW)
endif()

project(pyoctra VERSION 0.1)

file(GLOB_RECURSE CPP_HEADERS "${PROJECT_SOURCE_DIR}/../../include/octra/*.hpp")
set(QUOTED_CPP_HEADERS "")
foreach(filepath ${CPP_HEADERS})
message("${filepath}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/../../include/octra/" "pyoctra/octra/" relative_filepath ${filepath})
  set(QUOTED_CPP_HEADERS "${QUOTED_CPP_HEADERS}\"${relative_filepath}\", ")
endforeach()
message("CPP_HEADERS: ${QUOTED_CPP_HEADERS}")



file(GLOB_RECURSE C_HEADERS "${PROJECT_SOURCE_DIR}/../../include/octra/*.h")
set(QUOTED_C_HEADERS "")
foreach(filepath ${C_SOURCES})
message("${filepath}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/../../include/octra/" "octra/" relative_filepath ${filepath})
  set(QUOTED_C_HEADERS "${QUOTED_CPP_HEADERS}'${relative_filepath}', ")
endforeach()
message("C_HEADERS: ${QUOTED_C_HEADERS}")


# file(GLOB_RECURSE CPP_SOURCES "${PROJECT_SOURCE_DIR}/../../include/octra/*.cpp")
# set(QUOTED_C_HEADERS "")
# foreach(filepath ${C_SOURCES})
# message("${filepath}")
#     string(REPLACE "${PROJECT_SOURCE_DIR}/../../include/octra/" "octra/" relative_filepath ${filepath})
#   set(QUOTED_C_HEADERS "${QUOTED_CPP_HEADERS}'${relative_filepath}', ")
# endforeach()
# message("C_HEADERS: ${QUOTED_C_HEADERS}")

configure_file(${PROJECT_SOURCE_DIR}/setup.py.in
               ${PROJECT_BINARY_DIR}/setup.py.in @ONLY)

file(
  GENERATE
  OUTPUT ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/setup.py
  INPUT ${PROJECT_BINARY_DIR}/setup.py.in)

file(COPY ${PROJECT_SOURCE_DIR}/swig_src
     DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/pyoctra)

file(COPY ${PROJECT_SOURCE_DIR}/../../include/octra
     DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/pyoctra)

file(COPY ${PROJECT_SOURCE_DIR}/../../source/octra
     DESTINATION ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/pyoctra)

# file(COPY ${PROJECT_SOURCE_DIR}/../include/example
#      DESTINATION ${PROJECT_BINARY_DIR}/examplejs)

# add_custom_command(
#     OUTPUT ${PROJECT_BINARY_DIR}/examplejs/example/example_wrap.cxx
#     COMMAND swig -javascript -node -c++ -o ${PROJECT_BINARY_DIR}/examplejs/example/example_wrap.cxx ../../swig_src/src/example.i
#     WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/examplejs/example
# )
#
# file(COPY ${PROJECT_SOURCE_DIR}/../javascript/package.json
#      DESTINATION ${PROJECT_BINARY_DIR}/examplejs/package.json)
#
#
# file(COPY ${PROJECT_SOURCE_DIR}/../javascript/lib
#      DESTINATION ${PROJECT_BINARY_DIR}/examplejs)
#
# # file(COPY ${PROJECT_SOURCE_DIR}/../javascript/tsconfig.json
# #      DESTINATION ${PROJECT_BINARY_DIR}/examplejs/tsconfig.json)
#
# add_custom_command(
#     OUTPUT ${PROJECT_BINARY_DIR}/examplejs/build/Release/example.node
#     COMMAND node-gyp configure build
#     DEPENDS ${PROJECT_BINARY_DIR}/examplejs/example/example_wrap.cxx
#     WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/examplejs
# )

add_custom_target(
    RunCustomCommand ALL
    # DEPENDS ${PROJECT_BINARY_DIR}/examplejs/build/Release/example.node
    DEPENDS ${PROJECT_SOURCE_DIR}/../../bindings/pyoctra/setup.py
    # DEPENDS ${PROJECT_BINARY_DIR}/examplejs/build/Release/example.node
    COMMAND echo "Hello, World!"
    COMMENT "Running custom command"
    VERBATIM
)


# # Set the input header and source file paths
# set(HEADER_FILE input.h)
# set(SOURCE_FILE input.c)
#
# # Set the output combined source file
# set(OUTPUT_FILE combined_source.c)
#
# # Create a custom command to combine header and source file
# add_custom_command(
#     OUTPUT ${OUTPUT_FILE}
#     COMMAND ${CMAKE_COMMAND} -E copy ${HEADER_FILE} ${OUTPUT_FILE}
#     COMMAND ${CMAKE_COMMAND} -E append ${OUTPUT_FILE} ${SOURCE_FILE}
#     DEPENDS ${HEADER_FILE} ${SOURCE_FILE}
# )
#
# # Add a custom target to build the output file
# add_custom_target(combined_source DEPENDS ${OUTPUT_FILE})
#
# # Add your executable target using the combined source file
# add_executable(MyApp ${OUTPUT_FILE})
#
# # Add a dependency to ensure the combined_source target is built first
# add_dependencies(MyApp combined_source)
