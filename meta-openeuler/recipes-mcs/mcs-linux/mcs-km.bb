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
OPENEULER_LOCAL_NAME = "mcs"

# Select exactly one MCS kernel pedestal backend.  The generic SMP AMP
# implementation is the aarch64 backend; STM32MP2 machines advertise the
# m33copro feature.  Machines with a HiSilicon heterogeneous RISC-V core
# should set MCS_PEDESTAL = "hisi-riscv".
MCS_PEDESTAL ?= "${@bb.utils.contains('MACHINE_FEATURES', 'm33copro', 'stm32mp2', 'aarch64', d)}"
# x86-64 builds the separate mcs-x86 source tree, whose Makefile does not
# use the pedestal variables. Clear the default so the aarch64 backend is
# not requested for it.
MCS_PEDESTAL:x86-64 = ""

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
        # CONFIG_XEN in the kernel .config does not tell whether the MCS xen
        # backend is selected: aarch64 kernels may enable Xen guest support
        # while MCS runs the openamp stack. Select the backend from
        # MCS_FEATURES and pass it to kbuild explicitly.
        #
        # The pedestal variables select the single backend linked into
        # mcs_km.ko; empty values must be passed explicitly so that the
        # Makefile does not fall back to its aarch64 default.
        oe_runmake CONFIG_XEN=${@bb.utils.contains('MCS_FEATURES', 'xen', 'y', '', d)} \
                CONFIG_MCS_PED_AARCH64=${@bb.utils.contains('MCS_PEDESTAL', 'aarch64', 'y', '', d)} \
                CONFIG_MCS_PED_HISI_RISCV=${@bb.utils.contains('MCS_PEDESTAL', 'hisi-riscv', 'y', '', d)} \
                CONFIG_MCS_PED_STM32MP2=${@bb.utils.contains('MCS_PEDESTAL', 'stm32mp2', 'y', '', d)}
}

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
RPROVIDES:${PN} += "kernel-module-mcs-km"
RPROVIDES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'kernel-module-xen-mcsback', '', d)}"
RPROVIDES:${PN}:append:x86-64 = " kernel-module-eth-i210"

KERNEL_MODULE_AUTOLOAD += "${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs_km', '', d)}"
KERNEL_MODULE_AUTOLOAD += "${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'xen-mcsback', '', d)}"
