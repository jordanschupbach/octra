cmake_minimum_required(VERSION 3.10)

project(buildAll LANGUAGES CXX)

option(BUILD_TESTS "Build tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)
option(BUILD_PYTHON "Build python" ON)
option(BUILD_JAVASCRIPT "Build Javascript" ON)
option(BUILD_R "Build R" ON)
option(BUILD_RUST "Build Rust" OFF)

# TODO: make this only be done for dev builds
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(../cmake/ModernCppStarter/cmake/tools.cmake)
include(../cmake/CPM.cmake/cmake/CPM.cmake)

# add octra using cpm
CPMAddPackage(NAME octra SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../tests ${CMAKE_BINARY_DIR}/tests)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../examples ${CMAKE_BINARY_DIR}/examples)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../prebindings/pyoctra ${CMAKE_CURRENT_LIST_DIR}/../build/pyoctra )
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../prebindings/octrajs ${CMAKE_CURRENT_LIST_DIR}/../build/octrajs )
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../prebindings/octrars ${CMAKE_CURRENT_LIST_DIR}/../build/octrars )
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../prebindings/octraR ${CMAKE_CURRENT_LIST_DIR}/../build/octraR )
