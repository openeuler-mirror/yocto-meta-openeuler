# get extra config files from openeuler
FILESEXTRAPATHS_append := "${THISDIR}/files/:"

# as it's small, base-passwd's tar.gz is integrated in openEuler Embedded
# to avoid network download
SRC_URI = "file://${BPN}_${PV}.tar.gz \
           file://add_shutdown.patch \
           file://nobash.patch \
           file://noshadow.patch \
           file://input.patch \
           file://disable-docs.patch \
           file://kvm.patch \
           file://openeuler_secure_nologin.patch \
           "

# a workaround to fix the error ”useradd: /var/run/passwd: No such file or directory“
# it's caused by shadow-native where the patch "0002-Allow-for-setting-password-in-clear-text"
# cannot be applied， because openeuler's shadow version is 4.9, and the patch is suitable for
# 4.8.1. In future, this issue can be fixed through upgrade of poky(3.3.2)

do_install_append() {
    install -d -m 755 ${D}${localstatedir}/run
}

SYSROOT_DIRS += "${localstatedir}"

PACKAGES =+ "${PN}-var"

FILES_${PN}-var = "/run ${localstatedir}/run"
