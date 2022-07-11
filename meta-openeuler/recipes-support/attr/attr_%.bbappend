# main bbfile: yocto-poky/meta/recipes-support/attr/attr_2.5.1.bb

# attr version in openEuler
PV = "2.5.1"

SRC_URI += "file://attr/0001-bypass-wrong-output-when-enabled-selinux.patch \
            file://attr/0002-dont-skip-security.evm-when-copy-xattr.patch"

