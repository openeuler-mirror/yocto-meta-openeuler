# main bbfile: yocto-poky/meta/recipes-core/initscripts/init-system-helpers_1.60.bb

# As it's small, the tarball of init-system-helpers is integrated in openEuler Embedded
# to avoid network download.
PV = "debian-1.64"

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

LIC_FILES_CHKSUM = "file://debian/copyright;md5=c4ec20aa158fa9de26ee1accf78dcaae"

SRC_URI = "file://${BPN}_${PV}.tar.gz"
SRC_URI[md5sum] = "69ce302fe1ee5616f17281b0708e9922"
SRC_URI[sha256sum] = "abebfcc4bbed3ba291bf84840451125e7f1d5be37fcae81e171b673cb820d1d1"

S = "${WORKDIR}/${BP}"
