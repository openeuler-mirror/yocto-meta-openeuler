#Currently, we only use the compiled ZVM and Zephyr images.
SUMMARY = "ZVM Base Package"
DESCRIPTION = "Copy ZVM images"

PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGE = "${PN}"
PV = "1.0"

SRC_URI += " \
   file://zvm_host.elf \
   file://zephyr.bin \
   "
LICENSE = "Apache-2.0"

do_populate_lic[noexec] = "1"
# The do_install function to copy files to the deployment directory
do_install:append() {
    install -d ${DEPLOY_DIR_IMAGE}  

    install -m 0644 ${WORKDIR}/zephyr.bin ${DEPLOY_DIR_IMAGE}
    install -m 0644 ${WORKDIR}/zvm_host.elf ${DEPLOY_DIR_IMAGE}
}
