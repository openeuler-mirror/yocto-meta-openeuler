PV = "6.14"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI_append = " \
	file://${BP}.tar.bz2 \
	file://0001-CVE-2022-27239.patch \
	file://0002-CVE-2022-29869.patch \
	file://0003-setcifsacl-fix-comparison-of-actions-reported-by-cov.patch \
	file://0004-cifs-utils-work-around-missing-krb5_free_string-in-H.patch \
"

SRC_URI[sha256sum] = "6609e8074b5421295ff012a31f02ccd9a058415c619c81362ebb788dbf0756b8"

S = "${WORKDIR}/${BP}"

# keep the same as before, otherwise a large number of dependencies will be introduced
DEPENDS_remove = "libtalloc"
