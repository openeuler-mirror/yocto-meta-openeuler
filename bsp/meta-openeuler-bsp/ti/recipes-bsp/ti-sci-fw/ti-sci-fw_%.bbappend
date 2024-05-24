OPENEULER_REPO_NAME = "ti-linux-firmware"
SRC_URI = "file://ti-linux-firmware"
S = "${WORKDIR}/ti-linux-firmware"

PR:append = ".psdk1"

SYSFW_PREFIX:myd-am62x = "fs"
SYSFW_PREFIX:myd-am62-k3r5 = "fs"
