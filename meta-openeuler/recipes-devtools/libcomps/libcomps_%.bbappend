
PV = "0.1.19"

SRC_URI:prepend = "file://${PV}.tar.gz \
	file://backport-tests-Don-t-print-parsing-errors-during-tests.patch \
           "

S = "${WORKDIR}/${BP}"
