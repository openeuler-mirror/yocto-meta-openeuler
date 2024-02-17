# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-tools_2.13.9.bb

PV = "2.13.5"

SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        "
SRC_URI[sha256sum] = "526356d7ed9da6259f9d74592657e87c5cc7fffff9e1c5421dfbddc99e32d4b1"

S = "${WORKDIR}/${BP}"
