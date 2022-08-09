require selinux_common.inc
require ${BPN}.inc

LIC_FILES_CHKSUM = "file://COPYING;md5=393a5ca445f6965873eca0259a17f833"

SRC_URI = "file://policycoreutils/${BP}.tar.gz \
           file://policycoreutils/fix-fixfiles-N-date-function.patch;patchdir=.. \
           file://policycoreutils/fix-fixfiles-N-date-function-two.patch;patchdir=.. \
"
