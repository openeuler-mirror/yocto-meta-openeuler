PV = "22.3.1"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=c4fa2b50f55649f43060fa04b0919b9b"
SRC_URI[md5sum] = "996f58a94fe0b8b82b6795c42bd171ba"
SRC_URI[sha256sum] = "65fd48317359f3af8e593943e6ae1506b66325085ea64b706a998c6e83eeaf38"
require pypi-src-openeuler.inc

# remove poky conflict patches
SRC_URI_remove += " \
        file://0001-change-shebang-to-python3.patch \
        file://0001-Don-t-split-git-references-on-unicode-separators.patch \
        "

# apply openeuler patches
SRC_URI_append +=" \
        file://remove-existing-dist-only-if-path-conflicts.patch \
        file://dummy-certifi.patch \
"
