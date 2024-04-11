# openeuler version
PV = "2.30.0"

# setting openeuler name
OPENEULER_REPO_NAME = "SDL2"

# remove poky license
LIC_FILES_CHKSUM:remove = "file://LICENSE.txt;md5=68a088513da90254b2fbe664f42af315"

# add openeuler license
LIC_FILES_CHKSUM:append = "file://LICENSE.txt;md5=25231a5b96ccdd8f39eb53c07717be64"

# remove 2.0.20.bb SRC_URI
SRC_URI:remove = "\
           file://optional-libunwind-generic.patch \
           file://0001-sdlchecks.cmake-pass-cflags-to-the-appropriate-cmake.patch \
           file://0001-Fix-potential-memory-leak-in-GLES_CreateTextur.patch \
           "
SRC_URI:remove:class-native = " file://0001-Disable-libunwind-in-native-OE-builds-by-not-looking.patch"

# add 2.28.4.bb SRC_URI
SRC_URI:prepend = "file://SDL2-${PV}.tar.gz\
                  "
SRC_URI[sha256sum] = "888b8c39f36ae2035d023d1b14ab0191eb1d26403c3cf4d4d5ede30e66a4942c"

S = "${WORKDIR}/SDL2-${PV}"

# bb setting from 2.28.4
EXTRA_OECMAKE:remove = "-DSDL_X11_XVM=OFF \
                        -DSDL_X11_XFIXES=OFF \
                       "

PACKAGECONFIG:append= " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'pipewire  vulkan', d)} \
"

# attr from 2.28.4
PACKAGECONFIG[libusb] = ",,libusb1"
PACKAGECONFIG[libdecor] = "-DSDL_WAYLAND_LIBDECOR=ON,-DSDL_WAYLAND_LIBDECOR=OFF,libdecor,libdecor"
PACKAGECONFIG[pipewire] = "-DSDL_PIPEWIRE_SHARED=ON,-DSDL_PIPEWIRE_SHARED=OFF,pipewire"
PACKAGECONFIG[vulkan]    = "-DSDL_VULKAN=ON,-DSDL_VULKAN=OFF"

FILES:${PN} += "${datadir}/licenses/SDL2/LICENSE.txt"
