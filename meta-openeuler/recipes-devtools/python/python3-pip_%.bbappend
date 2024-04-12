PV = "23.3.1"
LIC_FILES_CHKSUM:remove = "\
    file://src/pip/_vendor/certifi/LICENSE;md5=67da0714c3f9471067b729eca6c9fbe8 \
    file://src/pip/_vendor/chardet/LICENSE;md5=a6f89e2100d9b6cdffcea4f398e37343 \
    file://src/pip/_vendor/distro.LICENSE;md5=d2794c0df5b907fdace235a619d80314 \
    file://src/pip/_vendor/pkg_resources/LICENSE;md5=9a33897f1bca1160d7aad3835152e158 \
    file://src/pip/_vendor/platformdirs/LICENSE.txt;md5=282c970bb844954c8535dd6e9733db7f \
    file://src/pip/_vendor/pygments/LICENSE;md5=98419e351433ac106a24e3ad435930bc \
    file://src/pip/_vendor/typing_extensions.LICENSE;md5=64fc2b30b67d0a8423c250e0386ed72f \
    file://src/pip/_vendor/html5lib/LICENSE;md5=1ba5ada9e6fead1fdc32f43c9f10ba7c \
    file://src/pip/_vendor/pep517/LICENSE;md5=aad69c93f605003e3342b174d9b0708c \
    file://src/pip/_vendor/progress/LICENSE;md5=00ab78a4113b09aacf63d762a7bb9644 \
"

LIC_FILES_CHKSUM:prepend = "\
    file://src/pip/_vendor/certifi/LICENSE;md5=3c2b7404369c587c3559afb604fce2f2 \
    file://src/pip/_vendor/chardet/LICENSE;md5=4fbd65380cdd255951079008b364516c \
    file://src/pip/_vendor/distro/LICENSE;md5=d2794c0df5b907fdace235a619d80314 \
    file://src/pip/_vendor/pkg_resources/LICENSE;md5=141643e11c48898150daa83802dbc65f \
    file://src/pip/_vendor/platformdirs/LICENSE;md5=ea4f5a41454746a9ed111e3d8723d17a \
    file://src/pip/_vendor/pygments/LICENSE;md5=36a13c90514e2899f1eba7f41c3ee592 \
    file://src/pip/_vendor/pyproject_hooks/LICENSE;md5=aad69c93f605003e3342b174d9b0708c \
    file://src/pip/_vendor/typing_extensions.LICENSE;md5=fcf6b249c2641540219a727f35d8d2c2 \
"

SRC_URI[sha256sum] = "1fcaa041308d01f14575f6d0d2ea4b75a3e2871fe4f9c694976f908768e14174"
require pypi-src-openeuler.inc

# remove poky conflict patches
SRC_URI:remove = " \
        file://0001-change-shebang-to-python3.patch \
        file://0001-Don-t-split-git-references-on-unicode-separators.patch \
        file://reproducible.patch \
        "

# apply openeuler patches
SRC_URI:append =" \
        file://remove-existing-dist-only-if-path-conflicts.patch \
        file://dummy-certifi.patch \
"
