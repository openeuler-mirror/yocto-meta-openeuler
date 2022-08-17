# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

# gzip version in openEuler
PV = "1.12"

# Use the source packages from openEuler
SRC_URI_remove = "${GNU_MIRROR}/gzip/${BP}.tar.gz"
SRC_URI_prepend += "file://${BP}.tar.xz \
                    file://performance-neoncrc32-and-prfm.patch \
                    file://fix-verbose-disable.patch \
                    "

# remove poky's conflicting patch
SRC_URI_remove_class-target = " file://wrong-path-fix.patch"

SRC_URI[md5sum] = "9608e4ac5f061b2a6479dc44e917a5db"
SRC_URI[sha256sum] = "ce5e03e519f637e1f814011ace35c4f87b33c0bbabeec35baf5fbd3479e91956"
