# openeuler PV
PV = "2.54.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# git-2.54.0.tar.xz sha256sum
SRC_URI[tarball.sha256sum] = "f689162364c10de79ef89aa8dbf48731eb057e34edbbd20aca510ce0154681a3"

# openeuler SRC_URI
SRC_URI:prepend = "file://${BP}.tar.xz \
                  "

# Remove patches written for git 2.46.0 that don't apply to 2.54.0
SRC_URI:remove = "file://fixsort.patch \
                  file://0001-config.mak.uname-do-not-force-RHEL-7-specific-build-.patch"

S = "${WORKDIR}/${BP}"
