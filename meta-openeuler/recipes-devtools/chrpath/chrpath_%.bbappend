PV = "0.18"

# apply openeuler source package and patches
# upstream source is codeberg release archive: release-0.18.tar.gz (extracts to chrpath/)
SRC_URI:prepend = "file://release-${PV}.tar.gz \
"

S = "${WORKDIR}/chrpath"
