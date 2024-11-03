if(NOT BUILD_TESTS)
  return()
endif()

cmake_minimum_required(VERSION 3.14...3.22)

project(OctraTests LANGUAGES C CXX)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)
option(TEST_INSTALLED_VERSION "Test the version found by find_package" OFF)

# --- Import tools ----

# include(../cmake/tools.cmake)

# ---- Dependencies ----

include(../cmake/CPM.cmake/cmake/CPM.cmake)

# CPMAddPackage("gh:doctest/doctest@2.4.9")
CPMAddPackage("gh:TheLartians/Format.cmake@1.7.3")


include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)


# if(TEST_INSTALLED_VERSION)
#   find_package(datamunge REQUIRED)
# else()
#   CPMAddPackage(NAME datamunge SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
# endif()

enable_testing()
# ---- Create binary ----

set(CMAKE_CXX_FLAGS "-g")
set(CMAKE_C_FLAGS "-g")

file(GLOB cpp_sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
file(GLOB c_sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.c)
message(STATUS "c_sources: ${c_sources}")
message(STATUS "cpp_sources: ${cpp_sources}")
add_executable(run_tests ${c_sources} ${cpp_sources})
target_link_libraries(run_tests 
  octra::octra
  GTest::gtest_main
)
set_target_properties(run_tests PROPERTIES CXX_STANDARD 17)


# # enable compiler warnings
# if(NOT TEST_INSTALLED_VERSION)
#   if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
#     target_compile_options(datamunge PUBLIC -Wall -Wpedantic -Wextra -Werror)
#   elseif(MSVC)
#     target_compile_options(datamunge PUBLIC /W4 /WX)
#     target_compile_definitions(${PROJECT_NAME} PUBLIC DOCTEST_CONFIG_USE_STD_HEADERS)
#   endif()
# endif()

# ---- Add DatamungeTests ----

# enable_testing()
# 
# # Note: doctest and similar testing frameworks can automatically configure CMake tests. For other
# # testing frameworks add the tests target instead: add_test(NAME ${PROJECT_NAME} COMMAND
# # ${PROJECT_NAME})
# 
# include(${doctest_SOURCE_DIR}/scripts/cmake/doctest.cmake)
# doctest_discover_tests(${PROJECT_NAME})
# 
# # ---- code coverage ----
# 
# if(ENABLE_TEST_COVERAGE)
#   target_compile_options(datamunge PUBLIC -O0 -g -fprofile-arcs -ftest-coverage)
#   target_link_options(datamunge PUBLIC -fprofile-arcs -ftest-coverage)
# endif()
