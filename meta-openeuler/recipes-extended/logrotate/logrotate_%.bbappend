# main bbfile: yocto-poky/meta/recipes-extended/logrotate/logrotate_3.18.0.bb

# version in openEuler
PV = "3.20.1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        https://github.com/${BPN}/${BPN}/releases/download/${PV}/${BP}.tar.xz \
"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BPN}/${BP}.tar.xz;name=tarball \
        file://${BPN}/0001-logrotate-3.20.1-lock-state-msg.patch \
"

SRC_URI[tarball.md5sum] = "24704642e1e6c7889edbe2b639636caf"
SRC_URI[tarball.sha256sum] = "742f6d6e18eceffa49a4bacd933686d3e42931cfccfb694d7f6369b704e5d094"
