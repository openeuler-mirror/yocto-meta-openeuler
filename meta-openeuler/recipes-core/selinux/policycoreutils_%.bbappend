PV = "3.5"

OPENEULER_SRC_URI_REMOVE = "https git http"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://fix-fixfiles-N-date-function.patch;patchdir=.. \
        file://fix-fixfiles-N-date-function-two.patch;patchdir=.. \
        "

S = "${WORKDIR}/selinux-${BP}/${BPN}"

RDEPENDS:${PN}:remove:class-target = "selinux-python"
