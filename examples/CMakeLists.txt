# if(NOT BUILD_EXAMPLES)
#   return()
# endif()

cmake_minimum_required(VERSION 3.14...3.22)

project(octraExamples LANGUAGES C CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -g ")

include(../cmake/ModernCppStarter/cmake/tools.cmake)
include(../cmake/CPM.cmake/cmake/CPM.cmake)
CPMAddPackage(NAME octra SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)

file(GLOB_RECURSE EXAMPLES "./source/*.c")
foreach(EXAMPLE IN LISTS EXAMPLES)
  get_filename_component(EXAMPLE_NAME ${EXAMPLE} NAME_WE)
  add_executable(${EXAMPLE_NAME}_c ${EXAMPLE})
  set_target_properties(${EXAMPLE_NAME}_c PROPERTIES C_STANDARD 11)
  target_link_libraries(${EXAMPLE_NAME}_c octra::octra)
endforeach()

file(GLOB_RECURSE EXAMPLES "./source/*.cxx")
foreach(EXAMPLE IN LISTS EXAMPLES)
  get_filename_component(EXAMPLE_NAME ${EXAMPLE} NAME_WE)
  add_executable(${EXAMPLE_NAME}_cxx ${EXAMPLE})
  set_target_properties(${EXAMPLE_NAME}_cxx PROPERTIES CXX_STANDARD 20)
  target_link_libraries(${EXAMPLE_NAME}_cxx octra::octra)
endforeach()
