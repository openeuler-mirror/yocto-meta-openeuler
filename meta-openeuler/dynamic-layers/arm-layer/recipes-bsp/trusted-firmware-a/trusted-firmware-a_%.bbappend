OPENEULER_REPO_NAME = "trusted-firmware-a"

PV:k3 = "git"

SRC_URI:k3 = " file://trusted-firmware-a "

LIC_FILES_CHKSUM=" file://docs/license.rst;md5=b5fbfdeb6855162dded31fadcd5d4dc5"

S:k3 = "${WORKDIR}/trusted-firmware-a"

CREATE_SRCIPK:k3 = "0"
