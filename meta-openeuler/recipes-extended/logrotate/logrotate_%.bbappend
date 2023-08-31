# main bbfile: yocto-poky/meta/recipes-extended/logrotate/logrotate_3.18.0.bb

# version in openEuler
PV = "3.20.1"

# files, patches can't be applied in openeuler or conflict with openeuler
# disable-check-different-filesystems.patch apply to 3.20.1 version fail
SRC_URI:remove = " \
        https://github.com/${BPN}/${BPN}/releases/download/${PV}/${BP}.tar.xz \
        file://disable-check-different-filesystems.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
        file://${BPN}/${BP}.tar.xz;name=tarball \
        file://${BPN}/0001-logrotate-3.20.1-lock-state-msg.patch \
        file://${BPN}/backport-do-not-rotate-old-logs-on-prerotate-failure.patch \
"
