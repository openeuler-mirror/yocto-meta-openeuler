# no bbfile in poky, refer to meta-oe bbfile: https://cgit.openembedded.org/meta-openembedded/tree/meta-oe/recipes-extended/rsyslog/rsyslog_8.2102.0.bb?h=hardknott

# version in openEuler
PV = "8.2110.0"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        http://www.rsyslog.com/download/files/download/rsyslog/${BPN}-${PV}.tar.gz \
"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.gz;name=tarball \
        file://rsyslog-8.24.0-ensure-parent-dir-exists-when-writting-log-file.patch \
        file://bugfix-rsyslog-7.4.7-imjournal-add-monotonic-timestamp.patch \
        file://bugfix-rsyslog-7.4.7-add-configuration-to-avoid-memory-leak.patch \
        file://rsyslog-8.37.0-initialize-variables-and-check-return-value.patch \
"

SRC_URI[tarball.md5sum] = "2d2b9d4a70a6e2fd4a7e806a5782c56b"
SRC_URI[tarball.sha256sum] = "3f904ec137ca6412e8273f7896d962ecb589f7d0c589bdf16b1709ec27e24f31"

# according to openEuler, no need to use flex-native liblogging libgcrypt
DEPENDS_remove = "flex-native liblogging"
PACKAGECONFIG_remove = "libgcrypt"

# current we not enable sysvint in DISTRO_FEATURES, just use busybox's init, but we want populate_packages_updatercd to work.
# In other word, we want update-rc.d always work when INITSCRIPT_NAME and INITSCRIPT_PARAMS generate with all none systemd scene.
# update-rc.d config from rsyslog_8.2102.0.bb : 
# INITSCRIPT_NAME = "syslog"
# INITSCRIPT_PARAMS = "defaults"
PACKAGESPLITFUNCS_prepend = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'populate_packages_updatercd ', d)}"
