
PV = "1.7.15"

SRC_URI = "file://v${PV}.tar.gz \
	file://backport-CVE-2023-50471_50472.patch \
	file://backport-fix-potential-memory-leak-in-merge_patch.patch \
"

S = "${WORKDIR}/cJSON-${PV}"
