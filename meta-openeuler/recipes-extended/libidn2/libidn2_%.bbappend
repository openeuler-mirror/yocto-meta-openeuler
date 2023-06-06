# main bbfile: yocto-poky/meta/recipes-extended/libidn/libidn2_2.3.0.bb

# version in openEuler
PV = "2.3.2"

# solve lic check failed
LIC_FILES_CHKSUM_remove = " \
        file://src/idn2.c;endline=16;md5=426b74d6deb620ab6d39c8a6efd4c13a \
        file://lib/idn2.h.in;endline=27;md5=c2cd28d3f87260f157f022eabb83714f \
"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/libidn/${BPN}-${PV}.tar.gz \
"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.gz;name=tarball \
        file://bugfix-libidn2-change-rpath.patch \
"

SRC_URI[tarball.md5sum] = "fb54962eb68cf22d47a4ae61f0aba993"
SRC_URI[tarball.sha256sum] = "76940cd4e778e8093579a9d195b25fff5e936e9dc6242068528b437a76764f91"
