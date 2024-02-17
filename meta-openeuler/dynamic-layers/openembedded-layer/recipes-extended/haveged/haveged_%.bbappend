PV = "1.9.18"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://fix-the-core-file-problem.patch \
        file://haveged.service \
        file://haveged.init \
"

S = "${WORKDIR}/${BP}"

inherit update-rc.d systemd

INITSCRIPT_NAME = "haveged"
INITSCRIPT_PARAMS = "start 03 2 3 4 5 . stop 30 0 6 1 ."
SYSTEMD_SERVICE:${PN} = "haveged.service"

do_install:append() {
    install -Dm 0644 ${WORKDIR}/haveged.service ${D}${systemd_system_unitdir}/haveged.service
    sed -i -e "s,@SBINDIR@,${sbindir},g" ${D}${systemd_system_unitdir}/haveged.service
    install -Dm 0755 ${WORKDIR}/haveged.init ${D}${sysconfdir}/init.d/haveged
    sed -i -e "s,@SBINDIR@,${sbindir},g" ${D}${sysconfdir}/init.d/haveged
}

