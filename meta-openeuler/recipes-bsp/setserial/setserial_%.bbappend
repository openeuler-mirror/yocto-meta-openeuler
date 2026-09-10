# Upstream recipe: yocto-poky/meta/recipes-bsp/setserial/setserial_2.17.bb
# Source: https://atomgit.com/src-openeuler/setserial (2.17, tarball is bit-identical to upstream)
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"
