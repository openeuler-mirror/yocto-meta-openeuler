SUMMARY = "ARM Neural Network SDK"
DESCRIPTION = "Linux software and tools to enable machine learning Tensorflow lite workloads on power-efficient devices"
LICENSE = "MIT & Apache-2.0"
# Apache-2.0 license applies to mobilenet tarball
LIC_FILES_CHKSUM = "file://LICENSE;md5=3e14a924c16f7d828b8335a59da64074 \
                    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PV_MAJOR = "${@d.getVar('PV',d,1).split('.')[0]}"
PV_MINOR = "${@d.getVar('PV',d,1).split('.')[1]}"

SRCREV = "0028d1b0ce5f4c2c6a6eb3c66f38111c21eb47a3"

SRCREV_FORMAT = "armnn"

S = "${WORKDIR}/git"

inherit cmake

BRANCH_ARMNN = "branches/armnn_${PV_MAJOR}_${PV_MINOR}"

SRC_URI = " \
    git://github.com/ARM-software/armnn.git;name=armnn;branch=${BRANCH_ARMNN} \
    file://0001-stdlib-issue-work-around.patch \
    file://0002-enable-use-of-boost-shared-library.patch \
    file://0003-generate-versioned-library.patch \
    file://0004-enable-use-of-arm-compute-shared-library.patch \
    file://0005-add-support-more-examples.patch \
    file://TfLiteMobilenetQuantized_0_25-Armnn.cpp \
    file://TfLiteMobilenetQuantized_1_0-Armnn.cpp \
    file://grace_hopper.jpg \
"

DEPENDS += " \
    boost \
    flatbuffers-native \
    flatbuffers \
    arm-compute-library \
    armnn-tensorflow-lite \
    stb \
"

RDEPENDS:${PN} = " arm-compute-library "

TESTVECS_INSTALL_DIR = "${datadir}/arm/armnn"

EXTRA_OEMAKE += "'LIBS=${LIBS}' 'CXX=${CXX}' 'CC=${CC}' 'AR=${AR}' 'CXXFLAGS=${CXXFLAGS}' 'CFLAGS=${CFLAGS}'"

do_configure:prepend() {
    install -m 0555 ${WORKDIR}/TfLiteMobilenetQuantized_0_25-Armnn.cpp ${S}/tests/TfLiteMobilenetQuantized-Armnn
    install -m 0555 ${WORKDIR}/TfLiteMobilenetQuantized_1_0-Armnn.cpp ${S}/tests/TfLiteMobilenetQuantized-Armnn
}

do_install:append() {
    CP_ARGS="-Prf --preserve=mode,timestamps --no-preserve=ownership"
    install -d ${D}${bindir}
    find ${WORKDIR}/build/tests -maxdepth 1 -type f -executable -exec cp $CP_ARGS {} ${D}${bindir} \;
    cp $CP_ARGS ${WORKDIR}/build/UnitTests  ${D}${bindir}

    chrpath -d ${D}${bindir}/*
}

FILES:${PN}-dev += "{libdir}/cmake/*"
INSANE_SKIP:${PN}-dev = "dev-elf"
