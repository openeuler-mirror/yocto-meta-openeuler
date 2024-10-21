cmake_minimum_required(VERSION 3.12)
project(Demo)

include_directories($ENV{PKG_CONFIG_SYSROOT_DIR}/usr/)
link_directories($ENV{PKG_CONFIG_SYSROOT_DIR}/usr/lib64)

find_package(OpenCV REQUIRED)

add_executable(ms-demo-class main.cc)  

target_link_libraries(
        ms-demo-class
        ${OpenCV_LIBS}
        mindspore-lite
        pthread
        dl
)

