PV = "21.3.1"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=c4fa2b50f55649f43060fa04b0919b9b"
SRC_URI[md5sum] = "0d3f27f4b7fecb33fd573e4f46cc6788"
SRC_URI[sha256sum] = "fd11ba3d0fdb4c07fbc5ecbba0b1b719809420f25038f8ee3cd913d3faa3033a"
require pypi-src-openeuler.inc

# remove poky conflict patches
SRC_URI_remove += " \
        file://0001-change-shebang-to-python3.patch \
        file://0001-Don-t-split-git-references-on-unicode-separators.patch \
        "

# apply openeuler patches
SRC_URI_append +=" \
        file://allow-stripping-given-prefix-from-wheel-RECORD-files.patch \
        file://emit-a-warning-when-running-with-root-privileges.patch \
        file://remove-existing-dist-only-if-path-conflicts.patch \
        file://dummy-certifi.patch \
"
