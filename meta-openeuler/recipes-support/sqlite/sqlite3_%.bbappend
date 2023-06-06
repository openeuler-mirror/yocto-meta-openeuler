# main bb file: yocto-poky/meta/recipes-support/sqlite/sqlite3_3.35.0.bb

# openEuler repo name
OPENEULER_REPO_NAME = "sqlite"

# version in openEuler
PV = "3.37.2"

# patches in src-openEuler are ready for sqlite-src

# this CVE had been fixed in 3.37.2 version
SRC_URI_remove = "file://CVE-2021-36690.patch \
"

SRC_URI[sha256sum] = "4089a8d9b467537b3f246f217b84cd76e00b1d1a971fe5aca1e30e230e46b2d8"
