# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/re2/re2_2020.11.01.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "2021-11-01"
S = "${WORKDIR}/${BPN}-${PV}"

# sync with high version of oe config:
# ignore .so in /usr/lib64
INSANE_SKIP_${PN} += "dev-so"

# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://${PV}.tar.gz \
    file://backport-fix-64-to-32-bit-clang-conversion-warning.patch \
    file://add-some-testcases-for-abnormal-branches.patch \
"

