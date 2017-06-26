cmake_minimum_required(VERSION 3.7)
project(mem_gui)

set(CMAKE_CXX_STANDARD 11)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall ")

set(SOURCE_FILES
        ftdi_wrapper/ftdi_wrapper.cpp
        uart_manager/uart_manager.cpp
        mem_gui.cpp status_manager/status_manager.cpp status_manager/status_manager.hpp memory_manager/memory_manager.cpp memory_manager/memory_manager.hpp generic_classes/generic_classes.hpp generic_classes/generic_classes.cpp)

include_directories(/usr/include/libftdi1/ ftdi_wrapper uart_manager uart_msg generic_classes)

add_executable(mem_gui ${SOURCE_FILES})

target_link_libraries(mem_gui ftdi1)