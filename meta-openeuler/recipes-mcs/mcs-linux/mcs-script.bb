### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "Init script for preparing mcs environment"
DESCRIPTION = "${SUMMARY}"
AUTHOR = ""
HOMEPAGE = "https://gitee.com/openeuler/mcs"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### License metadata
LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=74b1b7a7ee537a16390ed514498bf23c"


### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
OPENEULER_LOCAL_NAME = "mcs"

SRC_URI = " \
        file://mcs \
        file://mcs_cpu_offline.sh \
        "
S = "${WORKDIR}/mcs"

do_fetch[depends] += "mcs-linux:do_fetch"

DEPENDS = "update-rc.d-native"

OLD_SCRIPT="mcs_cpu_offline.sh"
INITD_DIR="${D}${sysconfdir}/init.d"

do_install:append () {
    install -d ${INITD_DIR}

    # If multiple cpus need to be turned offline, e.g. use MCS_CPUID_OFFLINE = "2 3"
    if [ ! -z "${MCS_CPUID_OFFLINE}" ]; then
        for cpu_id in ${MCS_CPUID_OFFLINE}; do
            NEW_SCRIPT="mcs_cpu${cpu_id}_offline.sh"
            SCRIPT_PATH="${INITD_DIR}/${NEW_SCRIPT}"
            install -m 0755 ${WORKDIR}/${OLD_SCRIPT} ${SCRIPT_PATH}
            sed -i "1s/.*/CPU_ID=${cpu_id}/" ${SCRIPT_PATH}
            update-rc.d -r ${D} ${NEW_SCRIPT} start 89 5 .
        done

        # TODO: handle systemd scripts
    fi
}

FILES:${PN} += "${sysconfdir}/init.d/"
FILES:${PN} += "${sysconfdir}/rc5.d/"
