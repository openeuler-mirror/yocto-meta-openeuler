require xen-openeuler.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://xen-init-dom0-tmpfiles.conf \
    file://xenconsoled-tmpfiles.conf \
    "

# xen-init-dom0 and xenconsoled can be pulled into sysinit via proc-xen.mount
# and then race systemd-tmpfiles-setup. Order them after tmpfiles and create
# the volatile targets first so libxl lockfiles and xenconsoled logs work.
do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_unitdir}/system/xen-init-dom0.service.d
        install -m 0644 ${WORKDIR}/xen-init-dom0-tmpfiles.conf \
            ${D}${systemd_unitdir}/system/xen-init-dom0.service.d/tmpfiles.conf

        install -d ${D}${systemd_unitdir}/system/xenconsoled.service.d
        install -m 0644 ${WORKDIR}/xenconsoled-tmpfiles.conf \
            ${D}${systemd_unitdir}/system/xenconsoled.service.d/tmpfiles.conf
    fi
}

FILES:${PN}-xencommons += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '${systemd_unitdir}/system/xen-init-dom0.service.d', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '${systemd_unitdir}/system/xenconsoled.service.d', '', d)} \
    "
