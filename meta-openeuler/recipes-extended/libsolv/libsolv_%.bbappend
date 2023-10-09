# main bbfile: yocto-poky/meta/recipes-extended/libsolv/libsolv_0.7.22.bb

OPENEULER_SRC_URI_REMOVE = "http https git"

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = " \
        git://github.com/openSUSE/libsolv.git;branch=master;protocol=https \
"

SRC_URI:prepend = "\
        file://${PV}.tar.gz \
        file://Fix-memory-leak-when-using-testsolv-to-execute-cases.patch \
"

# delete -DENABLE_RPMDB_BDB=ON, not used with new rpm version
PACKAGECONFIG[rpm] = "-DENABLE_RPMMD=ON -DENABLE_RPMDB=ON,,rpm"
