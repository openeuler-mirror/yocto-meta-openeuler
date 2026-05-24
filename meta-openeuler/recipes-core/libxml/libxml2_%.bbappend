# version in openEuler
PV = "2.11.9"

# remove all poky patches and apply openEuler source package
SRC_URI = "file://${BP}.tar.xz \
           file://libxml2-multilib.patch \
           "

PACKAGECONFIG:remove = "python"

# remove test configuration, because test package not in openEuler
do_configure:remove() {
        find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}
