OPENEULER_SRC_URI_REMOVE = "https"

LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f \
                    file://COPYING.LIB;md5=bbb461211a33b134d42ed5ee802b37ff \
                    file://LICENSES;md5=ef545b6cc717747072616519a1256d69 \
                    "

# version in openEuler
PV = "1.10.2"

SRC_URI_remove = "file://0003-tests-bench-slope.c-workaround-ICE-failure-on-mips-w.patch \
        file://0001-Makefile.am-add-a-missing-space.patch \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# patches in openEuler
SRC_URI_prepend = "\
    file://${BP}.tar.bz2 \
    file://no-native-gpg-error.patch \
    file://no-bench-slope.patch \
    file://Use-the-compiler-switch-O0-for-compiling-jitterentro.patch \
"

# checksum changed
SRC_URI[sha256sum] = "3b9c02a004b68c256add99701de00b383accccf37177e0d6c58289664cce0c03"
