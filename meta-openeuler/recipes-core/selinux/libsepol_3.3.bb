require selinux_common.inc
require ${BPN}.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=a6f89e2100d9b6cdffcea4f398e37343"

SRC_URI += "file://libsepol/${BP}.tar.gz"
CFLAGS +=  "${@bb.utils.contains('RTOS_KASAN', 'kasan', '-fcommon', '', d)}"
