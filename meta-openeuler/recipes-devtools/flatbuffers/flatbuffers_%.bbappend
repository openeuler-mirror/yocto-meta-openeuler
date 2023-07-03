PV = "2.0.0"

OPENEULER_BRANCH = "master"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRCREV = "3d79a88adb0eceb2ab5ff994c9b4c03b4b3c0daf"

EXTRA_OECMAKE:append:class-target = " -DFLATBUFFERS_BUILD_FLATC=0"

SRC_URI = " \
        file://v${PV}.tar.gz \
        file://0001-flatbuffers_cross_build_fix.patch \
"

SRC_URI:remove:class-native = " \
        file://0001-flatbuffers_cross_build_fix.patch \
"

S = "${WORKDIR}/${BP}"


