OPENEULER_REPO_NAME = "kernel-5.10"

PV = "5.10"

# apply openeuler source package and patches
SRC_URI:prepend = "file://kernel-${PV} \
"

S = "${WORKDIR}/kernel-${PV}"
