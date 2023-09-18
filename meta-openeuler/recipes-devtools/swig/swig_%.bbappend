PV = "4.0.2"

# remove original source
SRC_URI:remove = "${SOURCEFORGE_MIRROR}/${BPN}/${BPN}-${PV}.tar.gz"

# use openeuler source and patches
# yocto uses pcre not pcre2, so do not apply patches for pcre2 from openeuler
SRC_URI += "file://${BPN}/${BPN}-${PV}.tar.gz \
            file://Backport-php-8-support-from-upstream.patch \
            file://0001-Ruby-Fix-deprecation-warnings-with-Ruby-3.x.patch \
            file://0001-gcc-12-warning-fix-in-test-case.patch \
           "

# checksum of tar.gz for 4.0.2
SRC_URI[md5sum] = "7c3e46cb5af2b469722cafa0d91e127b"
SRC_URI[sha256sum] = "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
