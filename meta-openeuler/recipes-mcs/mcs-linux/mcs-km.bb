### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "The external linux kernel module of openEuler Embedded's MCS feature"
DESCRIPTION = "${SUMMARY}"
AUTHOR = ""
HOMEPAGE = "https://gitee.com/openeuler/mcs"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### License metadata
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

### Inheritance and includes if needed
inherit module
require mcs-resources-overlay.inc

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
PV = "0.0.1"
OPENEULER_REPO_NAME = "mcs"

SRC_URI:append:aarch64 = " \
    file://mcs/mcs_km \
    "
S = "${WORKDIR}/mcs/mcs_km"

# for x86
OPENEULER_LOCAL_NAME:x86-64 = "mcs-x86"
SRC_URI:append:x86-64 = " \
    file://mcs-x86/mcs_km \
    "
S:x86-64 = "${WORKDIR}/mcs-x86/mcs_km"

do_fetch[depends] += "mcs-linux:do_fetch"

# include jailhouse/Module.symvers for mcs_ivshmem.c
DEPENDS += "${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)}"

do_compile() {
        oe_runmake
}

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
RPROVIDES:${PN} += "kernel-module-mcs-km"
RPROVIDES:${PN}:x86-64 += "kernel-module-eth-i210"

KERNEL_MODULE_AUTOLOAD += "${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs_km', '', d)}"
