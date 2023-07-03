PV = "3.4"

SRC_URI:remove = "git://github.com/SELinuxProject/selinux.git;branch=master;protocol=https \
        file://libsemanage-allow-to-disable-audit-support.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://fix-fixfiles-N-date-function.patch;patchdir=.. \
        file://fix-fixfiles-N-date-function-two.patch;patchdir=.. \
        file://backport-python-Split-semanage-import-into-two-transactions.patch;patchdir=.. \
        file://backport-python-audit2allow-close-file-stream-on-error.patch;patchdir=.. \
        file://backport-semodule-avoid-toctou-on-output-module.patch;patchdir=.. \
        "

SRC_URI[md5sum] = "5af631db10479f2284ec92cacbf6c4c8"
SRC_URI[sha256sum] = "e49f26b7cb304777461142840ec6d6f00241fe565e162c0b24dfd7bcf31b369a"

S = "${WORKDIR}/selinux-${BP}/${BPN}"

RDEPENDS:${PN}:remove:class-target = "selinux-python"
