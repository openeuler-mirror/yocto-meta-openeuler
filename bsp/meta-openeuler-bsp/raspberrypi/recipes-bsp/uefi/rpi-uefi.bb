SUMMARY = "EDK2 Raspberry Pi 4 UEFI firmware"
# RPI_EFI.fd is BSD-2-Clause, licence is described in files/LICENCE.edk2
# licence of start*.elf, fixup*.dat are described in files/LICENCE.broadcom
# firmware files see LICENCE.txt

# we just need RPI_EFI.fd so here we present BSD-2-Clause here
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${THISDIR}/files/LICENCE.edk2;md5=2b415520383f7964e96700ae12b4570a"


SRC_URI = "file://RPi4_UEFI_Firmware_v1.33.zip \
           file://uefi-vars.fd \
"

SRC_URI[sha256sum] = "1de14df6caaeb61fd15065eee23fb1bae864a1ea15eba8ee066a94073660f8be"

inherit deploy nopackages

DEPENDS += "rpi-tf-a"

do_deploy() {
    # Use the bl31.bin we compiled to make a RPI_EFI.fd
    # bl31.bin is placed into the first 128KB of RPI_EFI.fd, filled up with 0xFF
    tr '\000' '\377' < /dev/zero | dd conv=notrunc bs=1K seek=0 count=128 of=${WORKDIR}/RPI_EFI.fd
    dd if=${WORKDIR}/recipe-sysroot/${datadir}/bl31.bin of=${WORKDIR}/RPI_EFI.fd conv=notrunc

    # pftf v1.33 persists its UEFI variables (SystemTableMode,
    # RamLimitTo3GB, ...) in the 128KB variable-store FV at the end of
    # RPI_EFI.fd on the boot volume, so there is no config.txt switch for
    # them. Overlay a preconfigured varstore (System Table Selection =
    # DEVICETREE, 3GB limit disabled) so a fresh image boots without
    # manual UEFI setup, which matters for headless boards.
    # NOTE: tied to the v1.33 firmware layout; regenerate the blob from a
    # working board if the firmware is ever upgraded.
    dd if=${WORKDIR}/uefi-vars.fd of=${WORKDIR}/RPI_EFI.fd conv=notrunc bs=65536 seek=29

    install -m 0644 ${WORKDIR}/RPI_EFI.fd ${DEPLOYDIR}
}

addtask deploy before do_build after do_install
do_deploy[dirs] += "${DEPLOYDIR}"
