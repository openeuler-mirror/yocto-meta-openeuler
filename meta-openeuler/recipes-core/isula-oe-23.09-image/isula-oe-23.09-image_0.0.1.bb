SUMMARY = "downloading openeuler container image"
DESCRIPTION = "The smallest isulad image is for running openeuler server version's container image"
LICENSE = "MulanPSLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d2effe8e0f44784c33108dbc1e00ba8c"

OPENEULER_LOCAL_NAME = "oee_archive"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}.tar.gz \
"

S = "${WORKDIR}/${BPN}"

do_install() {
	# install the container image to /containers
    install -d ${D}/containers
    install -m 0600 ${S}/${BPN}.tar.gz ${D}/containers/${BPN}.tar.gz
    gunzip ${D}/containers/${BPN}.tar.gz
    # if the os does not contain systemd, rely on init script to start isulad
    # to automatically start isulad when system boot, need to create soft link
    # in /etc/rcS.d
    # if the os contains systemd, rely on systemd service to start isulad
    # to automatically start isulad using systemd, need to create soft link
    # in /etc/systemd/system/multi-user.target.wants
    # the indentation of word "EOF" is important, do not change it
	if [ ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'True', 'False', d)} = "True" ]; then
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
		ln -sf ${sysconfdir}/systemd/system/isulad.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/isulad.service
	else
        install -d ${D}${sysconfdir}/init.d
        cat <<-EOF > ${D}${sysconfdir}/init.d/isulad
            #!/bin/sh
            # start isula daemon when system boot in background
            isulad &
EOF
        chmod 0755 ${D}${sysconfdir}/init.d/isulad
        install -d ${D}${sysconfdir}/rcS.d
        ln -sf ${sysconfdir}/init.d/isulad ${D}${sysconfdir}/rcS.d/S99isulad
    fi
}

FILES_${PN} += " \
    /containers/${BPN}.tar \
"

python () {
    if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d):
        # FILES_${PN} cannot be automatically expanded
        pn = d.getVar('PN', True)
        d.appendVar('FILES_'+pn, ' ${sysconfdir}/systemd/system/multi-user.target.wants/isulad.service')
    else:
        pn = d.getVar('PN', True)
        d.appendVar('FILES_'+pn, ' ${sysconfdir}/init.d/isulad')
        d.appendVar('FILES_'+pn, ' ${sysconfdir}/rcS.d/S99isulad')
}

RDEPENDS_${PN} += "isulad"
