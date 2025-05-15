# main bbfile: yocto-poky/meta/recipes-core/initrdscripts/initramfs-module-install-efi_1.0.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += "file://init-install-efi-openeuler.sh \
            file://install-efi@.service \
"

inherit systemd

SERIAL_CONSOLES ?= "115200;ttyS0"

RDEPENDS:${PN}:remove = "initramfs-framework-base"

# For pxe install
RDEPENDS:${PN}:append = " dhcp-client tftp-hpa"

do_install:append() {
        install -m 0755 ${WORKDIR}/init-install-efi-openeuler.sh ${D}/init.d/install-efi.sh

        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
                # deal with systemd unit files
                install -d ${D}${systemd_system_unitdir}
                install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
                install -m 0644 ${WORKDIR}/install-efi@.service ${D}${systemd_system_unitdir}

                ln -sf ${systemd_system_unitdir}/install-efi@.service \
                        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/install-efi@tty1.service

                if [ ! -z "${SERIAL_CONSOLES}" ] ; then
                        tmp="${SERIAL_CONSOLES}"
                        for entry in $tmp ; do
                                ttydev=`echo $entry | sed -e 's/^[0-9]*\;//' -e 's/\;.*//'`
                                # enable the service
                                ln -sf ${systemd_system_unitdir}/install-efi@.service \
                                        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/install-efi@$ttydev.service
                        done
                fi
        fi
}

FILES:${PN}  = " \
               /init.d/install-efi.sh \
               ${systemd_system_unitdir}/install-efi@.service \
               ${sysconfdir} \
"

SYSTEMD_SERVICE = "install-efi@.service"
