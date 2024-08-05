cmake_minimum_required(VERSION 3.10)

project(octra LANGUAGES C C++)

include(cmake/CPM.cmake/cmake/CPM.cmake)

CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")
# add_subdirectory(cmake/PackageProject.cmake) # maybe do it this way?
