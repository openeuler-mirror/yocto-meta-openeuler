OPENEULER_LOCAL_NAME = "kernel-6.6"

PV = "6.6"

# apply openeuler source package and patches
SRC_URI:prepend = "file://kernel-${PV} \
"

S = "${WORKDIR}/kernel-${PV}"
