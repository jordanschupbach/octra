cmake_minimum_required(VERSION 3.10)

project(octra 
  VERSION 
  0.0.1 
  LANGUAGES C CXX)

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()


include(cmake/CPM.cmake/cmake/CPM.cmake)
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")
# CPMAddPackage("gh:msgpack/msgpack-c#cpp-7.0.0")


# https://github.com/msgpack/msgpack-c.git

# Add any remaining dependencies here


# Gather source files
file(GLOB_RECURSE c_headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")
file(GLOB_RECURSE c_sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.c")
file(GLOB_RECURSE cxx_headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp")
file(GLOB_RECURSE cxx_sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cxx")
# TODO: adjust makefile to allow for printing debug messages
message(DEBUG "c_headers: ${c_headers}")
message(DEBUG "c_sources: ${c_sources}")
message(DEBUG "cxx_headers: ${cxx_headers}")
message(DEBUG "cxx_sources: ${cxx_sources}")


# TODO: find somewhere proper for these two lines
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")


# Add C shared library (TODO: add static library)
add_library(${PROJECT_NAME} SHARED ${c_headers} ${c_sources} )
set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 11)
target_compile_options(${PROJECT_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")
target_include_directories(
  ${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                         $<INSTALL_INTERFACE:include/${PROJECT_NAME}-${PROJECT_VERSION}>
)

string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)
# Package the C library
packageProject(
  NAME ${PROJECT_NAME}
  VERSION ${PROJECT_VERSION}
  NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION include/${PROJECT_NAME}-${PROJECT_VERSION}
  VERSION_HEADER "${VERSION_HEADER_LOCATION}"
  COMPATIBILITY SameMajorVersion
  DEPENDENCIES ""
)


# Add C++ shared library (TODO: add static library)
add_library(${PROJECT_NAME}pp SHARED ${c_headers} ${c_sources} ${cxx_headers} ${cxx_sources})
set_property(TARGET ${PROJECT_NAME}pp PROPERTY CXX_STANDARD 20)
target_compile_options(${PROJECT_NAME}pp PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")
target_include_directories(
  ${PROJECT_NAME}pp PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                         $<INSTALL_INTERFACE:include/${PROJECT_NAME}-${PROJECT_VERSION}>
)
string(TOLOWER ${PROJECT_NAME}/version.hpp VERSION_HEADER_PP_LOCATION)
# Package the C++ library
packageProject(
  NAME ${PROJECT_NAME}pp
  VERSION ${PROJECT_VERSION}
  NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION include/${PROJECT_NAME}-${PROJECT_VERSION}
  VERSION_HEADER "${VERSION_HEADER_PP_LOCATION}"
  COMPATIBILITY SameMajorVersion
  DEPENDENCIES ""
)
