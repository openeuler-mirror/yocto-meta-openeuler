# source bb: yocto-poky/meta/recipes-devtools/python/python3-ruamel-yaml_0.17.21.bb

PV = "0.18.6"

SRC_URI[sha256sum] = "8b27e6a217e786c6fbe5634d8f3f11bc63e0f80f6a5890f28863d9c45aac311b"
LIC_FILES_CHKSUM = "file://LICENSE;md5=30cbbccd94bf3a2b0285ec35671a1938"

require pypi-src-openeuler.inc
OPENEULER_LOCAL_NAME = "python3-ruamel-yaml"
