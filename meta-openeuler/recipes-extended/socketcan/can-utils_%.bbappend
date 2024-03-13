# main bb file: yocto-meta-openembedded/meta-oe/recipes-extended/socketcan/can-utils_git.bb


S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:remove = "git://github.com/linux-can/${BPN}.git;protocol=https;branch=master"
SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
                   "
SRC_URI[sha256sum] = "c9b8f29515ad34af7f78450ec55c983abc5393e86b1f128a92ac0dfd141baaf7"
