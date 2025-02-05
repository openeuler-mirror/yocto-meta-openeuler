OPENEULER_LOCAL_NAME = "kexec-tools"

PV = "1.7.4"

S = "${WORKDIR}/${BP}"

SRC_URI:prepend = "file://${BP}.tar.gz "
