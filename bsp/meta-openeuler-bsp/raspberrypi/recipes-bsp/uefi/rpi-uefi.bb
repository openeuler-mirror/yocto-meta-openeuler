SUMMARY = "EDK2 Raspberry Pi 4 UEFI firmware"
# RPI_EFI.fd is BSD-2-Clause, licence is described in files/LICENCE.edk2
# licence of start*.elf, fixup*.dat are described in files/LICENCE.broadcom
# firmware files see LICENCE.txt

# we just need RPI_EFI.fd so here we present BSD-2-Clause here
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${THISDIR}/files/LICENCE.edk2;md5=2b415520383f7964e96700ae12b4570a"


SRC_URI = " \
        file://yocto-embedded-tools/firmware/rasp-uefi/RPi4_UEFI_Firmware_v1.33.zip \
        "

inherit deploy nopackages

do_deploy() {
    install -m 0644 ${WORKDIR}/RPI_EFI.fd ${DEPLOYDIR}
}

addtask deploy before do_build after do_install
do_deploy[dirs] += "${DEPLOYDIR}"
