# main bbfile: yocto-poky/meta/recipes-kernel/powertop/powertop_2.14.bb

PV = "2.16.1"

# in 2.15, the following patch is already merged
SRC_URI:remove = " file://0001-src-fix-compatibility-with-ncurses-6.3.patch "

# src package from openEuler; the always-create-params backport is
# included in 2.16.1 and was dropped from the src repo
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        "

S = "${WORKDIR}/${BP}"
