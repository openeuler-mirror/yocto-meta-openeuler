DESCRIPTION = "Mindspore’s lightweight solution for mobile and embedded devices"
AUTHOR = "Huawei Technologies Co., Ltd"
HOMEPAGE = "https://www.mindspore.cn/lite"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

OPENEULER_REPO_NAME = "mindspore"

PROVIDES = "mindspore-lite"

DEPENDS = "zlib flatbuffers-native libjpeg-turbo python3-numpy-native python3-pybind11-native nlohmann-json"

SRC_URI = " \
    file://mindspore \ 
    file://yocto-mslite-aarch64-supprot.patch \
"

inherit cmake python3native pkgconfig

S = "${WORKDIR}/mindspore"

# install_cmake from mindspore use this default path for build, sync it.
B = "${WORKDIR}/mindspore/mindspore/lite/build"

EXTRA_OECMAKE = "\
    ${S}/mindspore/lite \
"
EXTRA_OECMAKE:prepend = " \
    -DENABLE_VERBOSE=off -DCMAKE_BUILD_TYPE=Release  -DENABLE_FAST_HASH_TABLE=ON \
    -DVERSION_STR=${PV} -DENABLE_ASAN=off \
    -DPLATFORM_ARM64=on \
    -DENABLE_NEON=on -DMSLITE_ENABLE_CONVERTER=off \
    -DMACHINE_LINUX_ARM64=on -DMSLITE_ENABLE_TRAIN=off -DMSLITE_GPU_BACKEND=off \
    -DMSLITE_REGISTRY_DEVICE=SD3403 -DMSLITE_COMPILE_TWICE=ON \
"

# ignore source compile warning
CFLAGS:append = " -Wno-error "
CXXFLAGS:append = " -Wno-error "

do_configure:prepend() {
    # use native flatbuffer, avoid download from source
    mkdir -p ${S}/mindspore/lite/providers/flatbuffer
    echo "${STAGING_DIR_NATIVE}/usr" > ${S}/mindspore/lite/providers/flatbuffer/native_flatbuffer.cfg
}
do_configure:append() {
    # need for build check
    echo "openEuler Embedded yocto" > ${B}/.commit_id
}

do_install:append() {
    mv ${D}/usr/mindspore-lite*/runtime/lib ${D}${libdir}
    mv ${D}/usr/mindspore-lite*/runtime/include ${D}${includedir}
    mv ${D}/usr/mindspore-lite*/runtime/third_party/securec/libsecurec.a ${D}${libdir}
    rm -rf ${D}/usr/mindspore-lite*
}

FILES:${PN} = "${libdir}/*so"
FILES:${PN}-staticdev = "${libdir}/*a"
FILES:${PN}-dev = "${includedir}"

INSANE_SKIP:${PN} += "already-stripped"
