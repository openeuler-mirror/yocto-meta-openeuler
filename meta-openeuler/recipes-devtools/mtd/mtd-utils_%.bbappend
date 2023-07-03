# main bb file: yocto-poky/meta/recipes-devtools/mtd/mtd-utils_git.bb

PV = "2.1.4"

SRC_URI:remove = "git://git.infradead.org/mtd-utils.git;branch=master"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
                   "
OPENEULER_BRANCH = "openEuler-22.03-LTS"

S = "${WORKDIR}/${BP}"

EXTRA_OECONF:remove = "--enable-install-tests"
