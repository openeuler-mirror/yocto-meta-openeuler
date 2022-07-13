# main bbfile: yocto-poky/meta/recipes-extended/less/less_563.bb

# less version in openEuler
PV = "590"

# Use the source packages from openEuler
SRC_URI_remove = "http://www.greenwoodsoftware.com/${BPN}/${BPN}-${PV}.tar.gz"
SRC_URI += "file://${BPN}/${BPN}-${PV}.tar.gz \
            file://${BPN}/less-394-time.patch \
            "

SRC_URI[md5sum] = "f029087448357812fba450091a1172ab"
SRC_URI[sha256sum] = "6aadf54be8bf57d0e2999a3c5d67b1de63808bb90deb8f77b028eafae3a08e10"

S = "${WORKDIR}/${BP}"
