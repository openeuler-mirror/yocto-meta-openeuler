DESCRIPTION = "ydlidar driver"                         
SECTION = "devel"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=4e320231d59c825e45dbfda066af29c9"

inherit cmake

inherit openeuler_source

SRC_URI = "file://0001-GS2.patch \
        file://0002-windows.patch \
        file://0003-GS1.patch \
        file://0004-S2-Pro.patch \
        file://0005-GS2-S2.patch \
        "
 
S = "${WORKDIR}/YDLidar-SDK-${PV}"
 
SRC_URI[md5sum] = "10d97fd77d76f1f754ef40b90a36ba17"
SRC_URI[sha256sum] = "88284d8fe5e567120d73d6967b840538f3f1975182db0ef0eb8233ac69023d1b"

DEPENDS = "swig-native python3"

SYSROOT_DIRS += "/usr/lib"

FILES:${PN}-staticdev += "/usr/lib/libydlidar_sdk.a"
FILES:${PN} += "/usr/share /usr/startup /usr/lib/python*"

# fix pkgconfig installdir conflict and driver compile warnings (which fix buffer overflow)
do_configure:prepend:class-target() {
    if [ -f ${S}/cmake/install_package.cmake ]; then
        cat ${S}/cmake/install_package.cmake | grep "\${CMAKE_INSTALL_DATAROOTDIR}\/pkgconfig" || sed -i 's:${CMAKE_INSTALL_PREFIX}/lib/pkgconfig:${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig:g' ${S}/cmake/install_package.cmake
        cat ${S}/cmake/install_package.cmake | grep "\${CMAKE_INSTALL_DATAROOTDIR}\/cmake" || sed -i 's:lib/cmake:${CMAKE_INSTALL_DATAROOTDIR}/cmake:g' ${S}/cmake/install_package.cmake
    fi
    sed -i 's:0x\%X thread has been canceled:0x\%lX thread has been canceled:g' ${S}/core/base/thread.h
    sed -i 's:Create thread 0x\%X:Create thread 0x\%lX:g' ${S}/src/YDlidarDriver.cpp
    sed -i 's:serialnum\[16\]:serialnum\[40\]:g' ${S}/core/common/ydlidar_protocol.h
}


BBCLASSEXTEND = "native nativesdk"

