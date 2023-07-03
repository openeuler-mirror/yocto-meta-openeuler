# main bbfile: yocto-poky/meta/recipes-support/lzo/lzo_2.10.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# attr version in openEuler
PV = "2.10"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            "

SRC_URI += " \
        file://${BPN}-${PV}.tar.gz \
        "

SRC_URI[tarball.md5sum] = "39d3f3f9c55c87b1e5d6888e1420f4b5"
SRC_URI[tarball.sha256sum] = "c0f892943208266f9b6543b3ae308fab6284c5c90e627931446fb49b4221a072"
