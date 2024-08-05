cmake_minimum_required(VERSION 3.10)

project(buildAll LANGUAGES CXX)

# NOTE: this should only be done for dev
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(../cmake/ModernCppStarter/cmake/tools.cmake)

option(BUILD_EXAMPLES "Build examples" ON)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../examples ${CMAKE_BINARY_DIR}/examples)
