# main bbfile: yocto-poky/meta/recipes-kernel/lttng/babeltrace2_2.0.4.bb

SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        "

S = "${WORKDIR}/${BP}"
