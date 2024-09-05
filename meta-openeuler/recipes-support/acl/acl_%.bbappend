# main bbfile: yocto-poky/meta/recipes-support/attr/acl_2.2.53.bb

# acl version in openEuler
PV = "2.3.2"


SRC_URI = "file://${BP}.tar.xz \
           file://backport-acl_copy_entry-Prevent-accidental-NULL-pointer-deref.patch \
"

# because PV is different,  the md5 and sha256 should also be updated
SRC_URI[md5sum] = "3cecb80cb0a52a0b273e6698ba642263"
SRC_URI[sha256sum] = "5f2bdbad629707aa7d85c623f994aa8a1d2dec55a73de5205bac0bf6058a2f7c"
