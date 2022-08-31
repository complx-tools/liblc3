cmake_minimum_required(VERSION 3.5)
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
endif(CMAKE_HOST_WIN32)

set(
    SRC_FILES
    source/ExpressionEvaluator.cpp
    source/lc3_assemble.cpp
    source/lc3.cpp
    source/lc3_debug.cpp
    source/lc3_execute.cpp
    source/lc3_expressions.cpp
    source/lc3_os.cpp
    source/lc3_osv2.cpp
    source/lc3_params.cpp
    source/lc3_parser.cpp
    source/lc3_plugin.cpp
    source/lc3_runner.cpp
    source/lc3_symbol.cpp
)

set(
    HEADER_FILES
    include/lc3_all.hpp
    include/lc3/ExpressionEvaluator.hpp
    include/lc3/lc3_assemble.hpp
    include/lc3/lc3.hpp
    include/lc3/lc3_debug.hpp
    include/lc3/lc3_execute.hpp
    include/lc3/lc3_expressions.hpp
    include/lc3/lc3_os.hpp
    include/lc3/lc3_params.hpp
    include/lc3/lc3_parser.hpp
    include/lc3/lc3_plugin.hpp
    include/lc3/lc3_runner.hpp
    include/lc3/lc3_symbol.hpp
)

add_library(
    lc3
    SHARED
)

target_sources(
    lc3
    PUBLIC
        # When 3.23 is standard across ubuntu distros switch to FILE_SET
        # FILE_SET HEADERS BASE_DIRS include FILES ${HEADER_FILES}
    PRIVATE
        ${SRC_FILES}
)

target_include_directories(
    lc3
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/include/lc3
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(
    lc3
    dl
    ${LIBLC3_EXTRA_LIBS}
)

export(
    TARGETS lc3
    NAMESPACE liblc3:: 
    FILE ${PROJECT_BINARY_DIR}/cmake/lc3/liblc3-export.cmake
)

install(
    TARGETS lc3
    EXPORT liblc3-export COMPONENT dev
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT runtime
    RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT runtime
    # FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT dev
)

install(
    EXPORT liblc3-export
    NAMESPACE   liblc3::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/lc3/cmake
    COMPONENT dev
)

install(
    FILES ${HEADER_FILES} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
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