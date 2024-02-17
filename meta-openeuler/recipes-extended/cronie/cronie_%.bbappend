PV = "1.6.1"

SRC_URI += " \
    file://cronie-${PV}.tar.gz \
    file://bugfix-cronie-systemd-alias.patch \
    file://backport-Support-reloading-with-SIGURG-in-addition-to-SIGHUP.patch \
"

SRC_URI[md5sum] = "de07b7229520bc859d987c721bab87c5"
SRC_URI[sha256sum] = "2cd0f0dd1680e6b9c39bf1e3a5e7ad6df76aa940de1ee90a453633aa59984e62"
