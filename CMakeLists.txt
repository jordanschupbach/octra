cmake_minimum_required(VERSION 3.10)

project(octra VERSION 0.0.1 LANGUAGES C CXX)

include(cmake/CPM.cmake/cmake/CPM.cmake)

CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")
# add_subdirectory(cmake/PackageProject.cmake) # maybe do it this way?

file(GLOB_RECURSE c_headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")
file(GLOB_RECURSE c_sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.c")
file(GLOB_RECURSE cxx_headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp")
file(GLOB_RECURSE cxx_sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cxx")


message(STATUS "c_headers: ${c_headers}")
message(STATUS "c_sources: ${c_sources}")
message(STATUS "cxx_headers: ${cxx_headers}")
message(STATUS "cxx_sources: ${cxx_sources}")

# Both built into single library for now...
add_library(${PROJECT_NAME} SHARED
  ${c_headers}
  ${c_sources}
  ${cxx_headers}
  ${cxx_sources})

# Can I set both standards?
# set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 11)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)

target_compile_options(${PROJECT_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")

target_include_directories(
  ${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                         $<INSTALL_INTERFACE:include/${PROJECT_NAME}-${PROJECT_VERSION}>
)

string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)

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
