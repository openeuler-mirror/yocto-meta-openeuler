COMPATIBLE_MACHINE = "qemu-aarch64|qemu-arm|raspberrypi4-64|ok3568"

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI = " \
	file://cells/ \
	"
JH_CELLS:ok3568 = "ok3568"
