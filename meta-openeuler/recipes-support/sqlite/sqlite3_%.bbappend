# main bb file: yocto-poky/meta/recipes-support/sqlite/sqlite3_3.38.5.bb

# version in openEuler
PV = "3.42.0"

# two .zip files in openEuler are not used, so patches don't work
SRC_URI = " \
    file://sqlite-autoconf-${SQLITE_PV}.tar.gz \
    "
# temporarily unapplicable patches:
# file://backport-0001-sqlite-no-malloc-usable-size.patch 
# file://backport-0002-remove-fail-testcase-in-no-free-fd-situation.patch  
# file://backport-0003-fix-memory-problem-in-the-rtree-test-suite.patch \
# file://backport-0004-CVE-2023-36191.patch 
# file://backport-CVE-2023-7104.patch 

SRC_URI[sha256sum] = "7abcfd161c6e2742ca5c6c0895d1f853c940f203304a0b49da4e1eca5d088ca6"
