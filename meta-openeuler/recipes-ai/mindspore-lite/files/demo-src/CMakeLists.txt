cmake_minimum_required(VERSION 3.12)
project(Demo)

include_directories($ENV{PKG_CONFIG_SYSROOT_DIR}/usr/)
link_directories($ENV{PKG_CONFIG_SYSROOT_DIR}/usr/lib64)

add_executable(ms-lite-demo main.cc)  

target_link_libraries(
        ms-lite-demo
        mindspore-lite
        pthread
        dl
)

