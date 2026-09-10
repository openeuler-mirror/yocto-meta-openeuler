# Upstream recipe: yocto-poky/meta/recipes-extended/lzip/lzip_1.23.bb
# Source: https://atomgit.com/src-openeuler/lzip (1.24.1)
# 1.24.1 is the closest available version to the upstream 1.23; the COPYING
# and decoder.cc license sections are byte-identical to 1.23, so the recipe's
# LIC_FILES_CHKSUM stays valid
PV = "1.24.1"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"

SRC_URI[sha256sum] = "30c9cb6a0605f479c496c376eb629a48b0a1696d167e3c1e090c5defa481b162"
