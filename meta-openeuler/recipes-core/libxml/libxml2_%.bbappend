# version in openEuler
PV = "2.11.5"

# remove all poky patches for 2.11.4 and apply openEuler source package
SRC_URI = "file://${BP}.tar.xz \
           file://libxml2-multilib.patch \
           file://backport-CVE-2023-45322.patch \
           file://backport-xpath-Remove-remaining-references-to-valueFrame.patch \
           file://backport-examples-Don-t-call-xmlCleanupParser-and-xmlMemoryDu.patch \
           file://backport-CVE-2024-25062.patch \
           "

# remove test configuration, because test package not in openEuler
do_configure:remove() {
	find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}
