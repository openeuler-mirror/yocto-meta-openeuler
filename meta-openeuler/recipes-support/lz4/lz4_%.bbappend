# main bbfile: yocto-poky/meta/recipes-support/lz4/lz4_1.9.3.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# attr version in openEuler
PV = "1.9.3"

S = "${WORKDIR}/${BPN}-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            file://CVE-2021-3520.patch \
            "

SRC_URI += " \
        file://${BPN}-${PV}.tar.gz \
        file://Fix-Data-Corruption-Bug-when-Streaming-with-an-Attac.patch \
        file://backport-CVE-2021-3520.patch \
        "

SRC_URI[tarball.md5sum] = "3a1ab1684e14fc1afc66228ce61b2db3"
SRC_URI[tarball.sha256sum] = "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1"
