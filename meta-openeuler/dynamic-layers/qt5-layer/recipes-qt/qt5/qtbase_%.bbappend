# main bbfile: meta-qt5/recipes-qt/qt5/qtbase_git.bb
require qt5-src.inc
require qtbase-src.inc

# License update
LIC_FILES_CHKSUM:remove = "file://LICENSE.QT-LICENSE-AGREEMENT;md5=c8b6dd132d52c6e5a545df07a4e3e283"
LIC_FILES_CHKSUM:prepend = "file://LICENSE.QT-LICENSE-AGREEMENT;md5=38de3b110ade3b6ee2f0b6a95ab16f1a \
"

# not need in version 5.15.10
# 0008 patch: use sched.h instead of pthread.h
# 0010 patch: fix glibc < 2 error
# 0023 patch: has been removed
SRC_URI:remove = "\
           file://0023-zlib-Do-not-undefine-_FILE_OFFSET_BITS.patch \
"


# openeuler configuration: 
# ref: meta-raspberrypi/dynamic-layers/qt5-layer/recipes-qt/qt5/qtbase_%.bbappend
PACKAGECONFIG_GL = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'gl', \
                        bb.utils.contains('DISTRO_FEATURES',     'opengl', 'eglfs gles2', \
                                                                       '', d), d)}"

PACKAGECONFIG_GL:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'kms gbm', '', d)}"

# font configuration
PACKAGECONFIG_FONTS = "fontconfig"
PACKAGECONFIG:append = " libinput examples tslib xkbcommon"
