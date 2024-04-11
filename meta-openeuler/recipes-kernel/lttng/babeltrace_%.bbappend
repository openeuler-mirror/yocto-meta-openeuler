# main bbfile: yocto-poky/meta/recipes-kernel/lttng/babeltrace_1.5.11.bb

PV = "1.5.11"

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        "

S = "${WORKDIR}/${BP}"

# Fix: QA Issue: babeltrace: Files/directories were installed but not shipped in any package
FILES:python3-${PN} += "/usr/lib"
