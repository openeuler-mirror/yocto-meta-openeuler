# main bbfile: yocto-poky/meta/recipes-kernel/wireless-regdb/wireless-regdb_2023.02.13.bb

# version in openEuler
PV = "2020.11.20"

SRC_URI:prepend = "file://${BP}.tar.xz "

# 2020 source lacks wens.key.pub.pem; use sforshee.key.pub.pem instead
do_install:prepend() {
    if [ -f ${S}/sforshee.key.pub.pem ]; then
        cp ${S}/sforshee.key.pub.pem ${S}/wens.key.pub.pem
    fi
}
