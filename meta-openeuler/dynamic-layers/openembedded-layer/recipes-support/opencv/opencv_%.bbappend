# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/opencv/opencv_4.5.2.bb

PV = "4.5.2"

OPENEULER_SRC_URI_REMOVE = "https git http"
OPENEULER_BRANCH = "master"
OPENEULER_REPO_NAME = "opencv"

# use src-openeuler's source
SRC_URI = " \
        file://opencv-${PV}.tar.gz \
        file://Fix-OpenCV-build-with-OpenEXR-before-2.2.0.patch \
        file://Fix_compilation_of_copy_assignment_operators_with_GCC.patch \
        file://Repair_clang_abi.patch \
        file://CVE-2022-0561_and_CVE-2022-0562.patch \
        file://CVE-2022-0908.patch \
        "

do_unpack_extra() {
}

S = "${WORKDIR}/opencv-4.5.2"

# no support of ade package in src-openeuler currently,
# so remove it from pkgconfig
PACKAGECONFIG:remove = "gapi"

# ippicv is not enable in src-openuler, so sync the config to our recipes
EXTRA_OECMAKE:append = " \
    -DWITH_IPP=OFF \
"
EXTRA_OECMAKE:remove = " \
    -DOPENCV_EXTRA_MODULES_PATH=${WORKDIR}/contrib/modules \
    -DOPENCV_ICV_HASH=${IPP_MD5} \
    -DIPPROOT=${WORKDIR}/ippicv_lnx \
    -DOPENCV_DOWNLOAD_PATH=${OPENCV_DLDIR} \
"

