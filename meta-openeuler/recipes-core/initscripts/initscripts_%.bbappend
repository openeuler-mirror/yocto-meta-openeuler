# we use openeuler's config files

FILESEXTRAPATHS_append := "${THISDIR}/files/:"

SRC_URI += " \
        file://populate-openeuler-volatile.sh \
        file://openeuler-safety-volatiles \
        "

# GPLv2.patch will create COPYING file, but if S dir is not a clean
# dir, i.e., COPYING file is already there because of last build,
# do patch may fail.
# A better solution is not using GPL2.patch.
# This fix can be removed if the upstream poky fix this
SRC_URI_remove = "file://GPLv2.patch"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

do_install_append() {
    install -d ${D}${sysconfdir}/default/openeuler-volatiles
    install -m 0644    ${WORKDIR}/openeuler-safety-volatiles     ${D}${sysconfdir}/default/openeuler-volatiles/00_core
    install -m 0755    ${WORKDIR}/populate-openeuler-volatile.sh ${D}${sysconfdir}/init.d
    #advice a low priority (99) to make it start later than any service and populate-volatile.sh
    update-rc.d -r ${D} populate-openeuler-volatile.sh start 99 S .
}

MASKED_SCRIPTS_append += " \
        populate-openeuler-volatile \
        "

pkg_postinst_${PN}_append () {
    # Delete any old volatile cache script, as directories may have moved
    if [ -z "$D" ]; then
        rm -f "/etc/openeuler-volatile.cache"
    fi
}
