# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/opencv/opencv_4.5.2.bb

PV = "4.5.2"

OPENEULER_SRC_URI_REMOVE = "https git http"
OPENEULER_BRANCH = "master"
OPENEULER_REPO_NAME = "opencv"

SRC_URI = "file://Fix-OpenCV-build-with-OpenEXR-before-2.2.0.patch \
           file://Fix_compilation_of_copy_assignment_operators_with_GCC.patch \
           file://Repair_clang_abi.patch \
           file://CVE-2022-0561_and_CVE-2022-0562.patch \
           file://CVE-2022-0908.patch \
           "
