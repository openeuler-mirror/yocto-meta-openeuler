OPENEULER_REPO_NAME = "gstreamer1"

FILESEXTRAPATHS:append := "${THISDIR}/gstreamer1.0/:"

PV = "1.24.0"

SRC_URI = " file://gstreamer-${PV}.tar.xz \
"

PACKAGECONFIG[tests] = ""

SRC_URI:append = "file://run-ptest \
           file://0001-tests-respect-the-idententaion-used-in-meson.patch \
           file://0003-tests-use-a-dictionaries-for-environment.patch \
"

SRC_URI[sha256sum] = "81c38617798d331269e389d56fb1388073e1dc9d489fe9bf2113f86b48b59138"
