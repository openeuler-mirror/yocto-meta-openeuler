PV = "3.5"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://fix-fixfiles-N-date-function.patch;patchdir=.. \
        file://fix-fixfiles-N-date-function-two.patch;patchdir=.. \
        file://backport-setfiles-avoid-unsigned-integer-underflow.patch;patchdir=.. \
        "

S = "${WORKDIR}/selinux-${BP}/${BPN}"

RDEPENDS:${PN}:remove:class-target = "selinux-python"

FILEEXTRAPATHS:prepend := "${THISDIR}/${PN}:${THISDIR}/${PN}/pam.d"
