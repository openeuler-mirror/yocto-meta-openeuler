# main bb file: yocto-poky/meta/recipes-devtools/mtd/mtd-utils_git.bb

PV = "2.1.4"

SRC_URI:prepend = " \
    file://${BP}.tar.bz2 \
    file://0001-tests-Remove-unused-linux-fs.h-header-from-includes.patch \
"

SRC_URI[sha256sum] = "2c6711d15d282c47cb3867b6857340597e26d332c238465134c602e5eef71b99"

S = "${WORKDIR}/${BP}"

EXTRA_OECONF:remove = "--enable-install-tests"
