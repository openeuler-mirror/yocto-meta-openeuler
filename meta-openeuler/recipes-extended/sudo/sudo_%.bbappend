# the main bb file: yocto-poky/meta/recipes-extended/sudo/sudo_1.9.13p3.bb

PV = "1.9.14p1"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=5100e20d35f9015f9eef6bdb27ba194f"

SRC_URI:remove = " \
            file://0001-sudo.conf.in-fix-conflict-with-multilib.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
            file://Fix-compilation-error-on-sw64-arch.patch \
"

SRC_URI[sha256sum] = "b9a0b1ae0f1ddd9be7f3eafe70be05ee81f572f6f536632c44cd4101bb2a8539"
