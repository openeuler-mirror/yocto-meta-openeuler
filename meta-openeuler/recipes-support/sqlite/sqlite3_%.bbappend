# main bb file: yocto-poky/meta/recipes-support/sqlite/sqlite3_3.38.5.bb
# openEuler repo name
OPENEULER_REPO_NAME = "sqlite"

# version in openEuler
PV = "3.42.0"

# two .zip files in openEuler are not used, so patches don't work
SRC_URI = " \
    file://sqlite-autoconf-${SQLITE_PV}.tar.gz \
    "

SRC_URI[sha256sum] = "7abcfd161c6e2742ca5c6c0895d1f853c940f203304a0b49da4e1eca5d088ca6"
