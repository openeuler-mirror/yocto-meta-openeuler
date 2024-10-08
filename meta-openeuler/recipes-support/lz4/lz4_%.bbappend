# main bbfile: yocto-poky/meta/recipes-support/lz4/lz4_1.9.3.bb

# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-support/lz4/lz4_1.9.4.bb
LICENSE = "BSD-2-Clause | GPL-2.0-only"
LIC_FILES_CHKSUM = "file://lib/LICENSE;md5=5cd5f851b52ec832b10eedb3f01f885a \
                    file://programs/COPYING;md5=492daf447d6db0e5eb344a7922e7ec25 \
                    file://LICENSE;md5=c111c47e301c2ffe8776729b40b44477 \
                    "

# attr version in openEuler
PV = "1.10.0"

S = "${WORKDIR}/${BP}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            file://CVE-2021-3520.patch \
            "

SRC_URI += " \
        file://${BP}.tar.gz \
        "

SRC_URI[tarball.md5sum] = "3a1ab1684e14fc1afc66228ce61b2db3"
SRC_URI[tarball.sha256sum] = "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1"

# 1.10.0 version need to change EXTRA_OEMAKE, otherwise some header files can't be found
EXTRA_OEMAKE = "DESTDIR=${D} BUILD_STATIC=no"
