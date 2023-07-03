# main bbfile: meta-oe/recipes-extended/rsyslog/rsyslog_8.2102.0.bb?h=hardknott

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# version in openEuler
PV = "8.2210.0"

# files, patches that come from openeuler
SRC_URI =+ " \
        file://rsyslog-8.24.0-ensure-parent-dir-exists-when-writting-log-file.patch \
        file://bugfix-rsyslog-7.4.7-imjournal-add-monotonic-timestamp.patch \
        file://bugfix-rsyslog-7.4.7-add-configuration-to-avoid-memory-leak.patch \
        file://rsyslog-8.37.0-initialize-variables-and-check-return-value.patch \
        file://backport-core-bugfix-local-hostname-invalid-if-no-global-config-object-given.patch  \
        file://backport-imtcp-bugfix-legacy-config-directives-did-no-longer-work.patch  \
"

SRC_URI[md5sum] = "23239f609af189b0814f8adc95ad9c02"
SRC_URI[sha256sum] = "643ee279139d694a07c9ff3ff10dc5213bdf874983d27d373525e95e05fa094d"

# according to openEuler, no need to use liblogging libgcrypt
DEPENDS:remove = "liblogging"
PACKAGECONFIG:remove = "libgcrypt"
