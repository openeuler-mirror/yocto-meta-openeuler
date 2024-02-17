# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/re2/re2_2020.11.01.bb

# version in openEuler
PV = "2021.11.01"
S = "${WORKDIR}/re2-2021-11-01"

# sync with high version of oe config:
# ignore .so in /usr/lib64
INSANE_SKIP:${PN} += "dev-so"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://2021-11-01.tar.gz \
    file://backport-fix-64-to-32-bit-clang-conversion-warning.patch \
    file://add-some-testcases-for-abnormal-branches.patch \
"
