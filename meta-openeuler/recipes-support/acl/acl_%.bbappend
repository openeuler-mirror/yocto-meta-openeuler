# main bbfile: yocto-poky/meta/recipes-support/attr/acl_2.2.53.bb

# acl version in openEuler
PV = "2.3.1"


SRC_URI:prepend = "file://${BP}.tar.gz "

# because PV is different,  the md5 and sha256 should also be updated
SRC_URI[md5sum] = "3cecb80cb0a52a0b273e6698ba642263"
SRC_URI[sha256sum] = "760c61c68901b37fdd5eefeeaf4c0c7a26bdfdd8ac747a1edff1ce0e243c11af"
