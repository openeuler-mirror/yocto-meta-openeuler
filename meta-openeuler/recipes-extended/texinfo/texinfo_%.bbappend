
PV = "7.0.3"

# openeuler source
SRC_URI:prepend = "file://${BP}.tar.xz \
           "
# for version 7.0.3, compare the differences in upstream recipe
SRC_URI[sha256sum] = "3cc5706fb086b895e1dc2b407aade9f95a3a233ff856273e2b659b089f117683"

# remove poky patch
SRC_URI:remove = " \
           file://0001-gnulib-Update.patch \
           "
# append do_install from texinfo_7.0.3 recipe
do_install:append() {
	sed -i -e 's,${HOSTTOOLS_DIR},,' ${D}${bindir}/texindex
}

# add files attribute
FILES:${PN}-doc = "${infodir}/texi* \
                   ${datadir}/${tex_texinfo} \
                   ${mandir}/man1 ${mandir}/man5"

S = "${WORKDIR}/${BP}"
