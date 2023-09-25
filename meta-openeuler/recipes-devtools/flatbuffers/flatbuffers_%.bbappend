PV = "23.5.26"

LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRCREV = "482e2ea3dc95339111ce48e1f4ae1ac646ad07b3"

EXTRA_OECMAKE:append:class-target = " -DFLATBUFFERS_BUILD_FLATC=0"

SRC_URI = " \
        file://flatbuffers-${PV}.tar.gz \
"

S = "${WORKDIR}/${BP}"


