# main bbfile: yocto-poky/meta/recipes-support/debianutils/debianutils_5.7.bb

# get extra tarball locally, because there is no debianutils src repository
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI:remove = "git://salsa.debian.org/debian/debianutils.git;protocol=https;branch=master"

SRC_URI += "file://${BP}.tar.gz"

SRC_URI[sha256sum] = "e9cdbef160b5adfd34536bab4c7a3d460b754e464d8011a020140b7434e01d88"
