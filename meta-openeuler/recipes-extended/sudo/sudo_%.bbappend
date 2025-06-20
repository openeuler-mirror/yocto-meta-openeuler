# the main bb file: yocto-poky/meta/recipes-extended/sudo/sudo_1.9.13p3.bb

PV = "1.9.15p5"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=5100e20d35f9015f9eef6bdb27ba194f"

SRC_URI:remove = " \
            file://0001-sudo.conf.in-fix-conflict-with-multilib.patch \
            file://0001-lib-util-mksigname.c-correctly-include-header-for-ou.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
            file://Fix-compilation-error-on-sw64-arch.patch \
            file://backport-If-user-s-tty-goes-away-tell-monitor-to-revoke-the-t.patch \
            file://backport-Avoid-using-ioctl-TIOCNOTTY-in-the-monitor.patch \
"

SRC_URI[sha256sum] = "558d10b9a1991fb3b9fa7fa7b07ec4405b7aefb5b3cb0b0871dbc81e3a88e558"
