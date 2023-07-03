# the main bb file: yocto-poky/meta/recipes-extended/sudo/sudo_1.9.13p3.bb

PV = "1.9.12p2"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=7aacba499777b719416b293d16f29c8c"

SRC_URI:remove = "https://www.sudo.ws/dist/sudo-${PV}.tar.gz \
            file://0001-sudo.conf.in-fix-conflict-with-multilib.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
            file://backport-CVE-2023-27320.patch \
"

SRC_URI[sha256sum] = "b9a0b1ae0f1ddd9be7f3eafe70be05ee81f572f6f536632c44cd4101bb2a8539"
