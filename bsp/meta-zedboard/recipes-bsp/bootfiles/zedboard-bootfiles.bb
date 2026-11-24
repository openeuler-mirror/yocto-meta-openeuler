SUMMARY = "ZedBoard boot script and PL bitstream"
DESCRIPTION = "Generates boot.scr for the U-Boot distro flow and installs the \
vendor PL bitstream when it is available locally."
LICENSE = "CLOSED"

SRC_URI = "file://boot.cmd"

S = "${WORKDIR}"

inherit deploy

DEPENDS += "u-boot-mkimage-native"

# Path to the bitstream extracted from the vendor BOOT.BIN. It is not part of
# the repository (vendor binary); when absent the image still builds and the
# boot script simply skips PL programming.
ZEDBOARD_BITSTREAM ?= "${THISDIR}/../../files/bitstream/system.bit.bin"

do_compile() {
	${STAGING_BINDIR_NATIVE}/mkimage -A arm -O linux -T script -C none \
		-n "ZedBoard boot script" -d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
}

do_deploy() {
	install -m 0644 ${WORKDIR}/boot.scr ${DEPLOYDIR}/boot.scr

	if [ -f "${ZEDBOARD_BITSTREAM}" ]; then
		install -m 0644 "${ZEDBOARD_BITSTREAM}" ${DEPLOYDIR}/system.bit.bin
	else
		bbwarn "ZEDBOARD_BITSTREAM (${ZEDBOARD_BITSTREAM}) not found, PL will not be programmed"
	fi
}

addtask deploy before do_build after do_install