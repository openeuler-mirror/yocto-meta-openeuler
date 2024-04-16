# main bbfile: yocto-poky/meta/recipes-kernel/powertop/powertop_2.14.bb

PV = "2.15"

# in 2.15, the following patch is already merged
SRC_URI:remove = " file://0001-src-fix-compatibility-with-ncurses-6.3.patch "

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        file://backport-powertop-2.7-always-create-params.patch \
        "

S = "${WORKDIR}/${BP}"
