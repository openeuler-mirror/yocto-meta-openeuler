# main bbfile: yocto-poky/meta/recipes-support/libatomic-ops/libatomic-ops_7.6.10.bb

PV = "7.8.2"

# apply src from openEuler (tarball uses underscore in name)
SRC_URI:prepend = "file://libatomic_ops-${PV}.tar.gz \
                "
