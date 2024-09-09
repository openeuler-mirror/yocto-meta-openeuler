# the main bb file: yocto-poky/meta/recipes-core/libcgroup/libcgroup_2.0.2.bb

PV = "3.1.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=4d794c5d710e5b3547a6cc6a6609a641"

SRC_URI:prepend = " \
            file://${BP}.tar.gz \
            file://config.patch \
"

SRC_URI[sha256sum] = "976ec4b1e03c0498308cfd28f1b256b40858f636abc8d1f9db24f0a7ea9e1258"

PACKAGECONFIG = "${@bb.utils.filter('DISTRO_FEATURES', 'pam systemd', d)}"
PACKAGECONFIG[systemd] = "--enable-systemd,--disable-systemd,systemd"
