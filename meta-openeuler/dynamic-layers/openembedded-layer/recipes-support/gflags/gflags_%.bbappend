# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/gflags/gflags_2.2.2.bb
# version in openEuler
PV = "2.2.2"
S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"
