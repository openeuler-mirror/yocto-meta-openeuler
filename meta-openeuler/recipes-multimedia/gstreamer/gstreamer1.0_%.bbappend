OPENEULER_REPO_NAME = "gstreamer1"

PV = "1.19.3"

SRC_URI_remove = "https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-${PV}.tar.xz \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=69333daa044cb77e486cc36129f7a770 \
                    file://gst/gst.h;beginline=1;endline=21;md5=e059138481205ee2c6fc1c079c016d0d"

SRC_URI_prepend = "file://gstreamer-${PV}.tar.xz \
            file://gstreamer-inspect-rpm-format.patch \
            file://0001-gstreamer-1.19.3-add-loongarch64-support.patch \
           "

SRC_URI[sha256sum] = "906d7d4bf92f941586c0cbce717d9cad6aac36994e16fa6f2f153e07e3221bca"
