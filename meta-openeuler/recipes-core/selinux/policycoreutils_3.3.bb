require selinux_common.inc
require ${BPN}.inc

LIC_FILES_CHKSUM = "file://COPYING;md5=393a5ca445f6965873eca0259a17f833"

SRC_URI = "file://policycoreutils/${BP}.tar.gz \
           file://policycoreutils/fix-fixfiles-N-date-function.patch;patchdir=.. \
           file://policycoreutils/fix-fixfiles-N-date-function-two.patch;patchdir=.. \
           file://backport-newrole-check-for-crypt-3-failure.patch;patchdir=.. \
           file://backport-newrole-ensure-password-memory-erasure.patch;patchdir=.. \
           file://backport-semodule_package-Close-leaking-fd.patch;patchdir=.. \
           file://backport-python-Split-semanage-import-into-two-transactions.patch;patchdir=.. \
           file://backport-python-audit2allow-close-file-stream-on-error.patch;patchdir=.. \
"
