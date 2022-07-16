# main bbfile: yocto-poky/meta/recipes-support/nettle/nettle_3.7.2.bb

# version in openEuler
PV = "3.7.3"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/${BPN}/${BP}.tar.gz \
"

# files, patches that come from openeuler
# don't apply 0000-nettle-3.3-remove-ecc-testsuite.patch due to failure: "No known curve with name secp192r1"
SRC_URI += " \
        file://${BP}.tar.gz;name=tarball \
"

SRC_URI[tarball.md5sum] = "a60273d0fab9c808646fcf5e9edc2e8f"
SRC_URI[tarball.sha256sum] = "661f5eb03f048a3b924c3a8ad2515d4068e40f67e774e8a26827658007e3bcf0"
