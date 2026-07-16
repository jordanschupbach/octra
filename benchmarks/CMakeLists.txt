cmake_minimum_required(VERSION 3.14...3.22)

project(OctraBenchmarks LANGUAGES CXX)

include(../cmake/CPM.cmake)

CPMAddPackage(NAME octra SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)

add_executable(splitmix64_bench cpp/splitmix64_bench.cpp)
target_link_libraries(splitmix64_bench PRIVATE octra::octra)
set_target_properties(splitmix64_bench PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED YES)
