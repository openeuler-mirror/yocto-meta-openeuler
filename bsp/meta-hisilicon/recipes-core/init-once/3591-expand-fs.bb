SUMMARY = "Automatic file system expansion"
DESCRIPTION = "Expand file system to use all the space on the card at first boot"
SECTION = "base"
LICENSE = "CLOSED"

RDEPENDS:${PN} = "parted e2fsprogs-resize2fs"

# init_once.sh: 
# perform the partition resize,resize file system, add BSP users at first boot/login
# this script use expect func, so need login to exec it. we use /etc/profile as a workaround
# see: bsp/meta-hisilicon/recipes-core/images/3591rc.inc delete_unneeded_and_make_first_boot
SRC_URI = "file://init_once.sh \
           "

S = "${WORKDIR}"

FILES:${PN} = "/sbin/init_once.sh"

do_install () {
	install -d ${D}/sbin/
	install -m 0755 ${WORKDIR}/init_once.sh ${D}/sbin/
}

ALLOW_EMPTY:${PN} = "1"
