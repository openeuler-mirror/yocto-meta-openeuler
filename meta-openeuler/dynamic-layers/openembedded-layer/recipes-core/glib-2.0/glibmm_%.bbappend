# main bb: yocto-meta-openembedded/meta-oe/recipes-core/glib-2.0/glibmm_2.66.2.bb

OPENEULER_LOCAL_NAME = "glibmm24"

PV = "2.66.5"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BP}.tar.xz \
        file://${OPENEULER_LOCAL_NAME}/glibmm24-gcc11.patch \
"

S = "${WORKDIR}/${BP}"
