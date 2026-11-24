cmake_minimum_required(VERSION 3.24)
project(veyra_xbox_offline LANGUAGES CXX)

get_filename_component(VEYRA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../.." ABSOLUTE)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
# Log.cpp forwards frame events to the opt-in private frame trace, so both sources form veyra_base,
# matching the main build.
add_library(veyra_base STATIC
  "${VEYRA_ROOT}/src/base/Log.cpp"
  "${VEYRA_ROOT}/src/base/PrivateFrameTrace.cpp")
target_include_directories(veyra_base PUBLIC "${VEYRA_ROOT}/include")
target_compile_features(veyra_base PUBLIC cxx_std_20)
target_compile_definitions(veyra_base PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
include("${VEYRA_ROOT}/cmake/VeyraWarnings.cmake")
include("${VEYRA_ROOT}/cmake/VeyraXbox.cmake")
