# version in openEuler
PV = "2.11.4"

OPENEULER_SRC_URI_REMOVE = "git https http"

# remove all poky patches for 2.11.4 and apply openEuler source package
SRC_URI = "file://${BP}.tar.xz \
           file://libxml2-multilib.patch \
           "

# remove test configuration, because test package not in openEuler
do_configure:remove() {
	find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}
