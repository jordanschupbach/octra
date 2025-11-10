cmake_minimum_required(VERSION 3.14...3.22)

project(octraExamples LANGUAGES CXX)

# --- Import tools ----

include(../cmake/ModernCppStarter/cmake/tools.cmake)

# ---- Dependencies ----

include(../cmake/CPM.cmake/cmake/CPM.cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "")
if(CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
      ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()



CPMAddPackage(NAME octra SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DLOG_LEVEL_BUILD=7")

file(GLOB_RECURSE CPP_EXAMPLES CONFIGURE_DEPENDS "./source/*.cpp")
message("C++ examples found: ${CPP_EXAMPLES}")
foreach(EXAMPLE IN LISTS CPP_EXAMPLES)
  get_filename_component(EXAMPLE_NAME ${EXAMPLE} NAME_WE)
  add_executable(${EXAMPLE_NAME}_cpp ${EXAMPLE})
  set_target_properties(${EXAMPLE_NAME}_cpp PROPERTIES CXX_STANDARD 23)
  set_property(TARGET ${EXAMPLE_NAME}_cpp PROPERTY CXX_STANDARD_REQUIRED ON)
  target_link_libraries(${EXAMPLE_NAME}_cpp octra::octra) #  blas lapack cblas lapacke
endforeach()

# file(GLOB_RECURSE C_EXAMPLES CONFIGURE_DEPENDS "./source/*.c")
# foreach(EXAMPLE IN LISTS C_EXAMPLES)
#   get_filename_component(EXAMPLE_NAME ${EXAMPLE} NAME_WE)
#   add_executable(${EXAMPLE_NAME}_c ${EXAMPLE})
#   set_property(TARGET ${EXAMPLE_NAME}_c PROPERTY C_STANDARD 11)
#   set_property(TARGET ${EXAMPLE_NAME}_c PROPERTY C_STANDARD_REQUIRED ON)
#   target_link_libraries(${EXAMPLE_NAME}_c octra::octra) #  lapack blas cblas lapacke
# endforeach()
