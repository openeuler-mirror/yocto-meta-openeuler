# main bbfile: yocto-poky/meta/recipes-kernel/lttng/babeltrace_1.5.11.bb

PV = "1.5.8"

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://backport-python3-Mapping-function-change-lead-to-build-failed.patch \
        "

S = "${WORKDIR}/${BP}"
