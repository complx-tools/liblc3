cmake_minimum_required(VERSION 3.23)
# Ignore warnings about rpath behavior on OS X
cmake_policy(SET CMP0042 NEW)
project(liblc3 LANGUAGES CXX)
include(GNUInstallDirs)


# Add code coverage stuff.
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(ENABLE_TESTS "Enable testing" OFF)
option(ENABLE_COVERAGE "Enable testing coverage" OFF)

if(ENABLE_TESTS)
    enable_testing()
endif(ENABLE_TESTS)

# Require C++11 build
if(NOT CMAKE_CXX_FLAGS MATCHES "-std=(c|gnu)\\+\\+11")
    message(STATUS "This project requires C++11. Adding -std=c++11 to CXXFLAGS.")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11" CACHE STRING "Flags used by the compiler during all build types." FORCE)
endif()

# Additional debug flags
set(CMAKE_CXX_FLAGS_DEBUG "-g -pg")
# Install directories
set(CMAKE_INSTALL_LIBDIR lib CACHE STRING "where to install libraries/plugins")
set(CMAKE_INSTALL_BINDIR bin CACHE STRING "where to install programs")

if(ENABLE_COVERAGE)
    include(CodeCoverage)
    append_coverage_compiler_flags()
endif(ENABLE_COVERAGE)


# Set default warning flags
set(PROJECT_WARNING_FLAGS "-Wall -Wno-deprecated -Wno-deprecated-declarations" CACHE STRING "Compiler warning flags to include")
mark_as_advanced(PROJECT_WARNING_FLAGS)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PROJECT_WARNING_FLAGS}")

# Default to release build if not specified
if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif(NOT CMAKE_BUILD_TYPE)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(CMAKE_EXE_LINKER_FLAGS "-fprofile-arcs -ftest-coverage")
endif(CMAKE_BUILD_TYPE MATCHES "Debug")

add_definitions(-DPREFIX=${CMAKE_INSTALL_PREFIX})
add_definitions(-DSO_SUFFIX="${CMAKE_SHARED_LIBRARY_SUFFIX}")

if(CMAKE_HOST_WIN32)
    # Needed for htons
    set(LIBLC3_EXTRA_LIBS ws2_32)
    # Windows doesn't set include directories correctly?
    #include_directories("C:/msys/1.0/local/lib/wx/include/msw-unicode-3.0")
    #include_directories("C:/msys/1.0/local/include/wx-3.0")
endif(CMAKE_HOST_WIN32)

file(
    GLOB 
    SRC_FILES ${PROJECT_SOURCE_DIR}/source/*.cpp
)

add_library(
    lc3
    SHARED
)

target_sources(
    lc3
    PUBLIC
        FILE_SET HEADERS BASE_DIRS include
    PRIVATE
        ${SRC_FILES}
)

target_link_libraries(
    lc3
    dl
    ${LIBLC3_EXTRA_LIBS}
)

export(
    TARGETS lc3
    NAMESPACE liblc3:: 
    FILE ${PROJECT_BINARY_DIR}/cmake/liblc3/liblc3-export.cmake
)

install(
    TARGETS lc3
    EXPORT liblc3
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/liblc3
)

install(
    EXPORT lc3
    NAMESPACE   liblc3::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/liblc3/cmake
)

if(ENABLE_TESTS)
    add_subdirectory(tests)
endif(ENABLE_TESTS)

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
