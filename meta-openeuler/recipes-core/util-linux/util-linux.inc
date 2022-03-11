SUMMARY = "A suite of basic system administration utilities"
HOMEPAGE = "https://en.wikipedia.org/wiki/Util-linux"
DESCRIPTION = "Util-linux includes a suite of basic system administration utilities \
commonly found on most Linux systems.  Some of the more important utilities include \
disk partitioning, kernel message management, filesystem creation, and system login."

SECTION = "base"

LICENSE = "GPLv2+ & LGPLv2.1+ & BSD-3-Clause & BSD-4-Clause"
LICENSE_${PN}-libblkid = "LGPLv2.1+"
LICENSE_${PN}-libfdisk = "LGPLv2.1+"
LICENSE_${PN}-libmount = "LGPLv2.1+"
LICENSE_${PN}-libsmartcols = "LGPLv2.1+"

LIC_FILES_CHKSUM = "file://README.licensing;md5=0fd5c050c6187d2bf0a4492b7f4e33da \
                    file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://Documentation/licenses/COPYING.GPL-2.0-or-later;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://Documentation/licenses/COPYING.LGPL-2.1-or-later;md5=4fbd65380cdd255951079008b364516c \
                    file://Documentation/licenses/COPYING.BSD-3-Clause;md5=58dcd8452651fc8b07d1f65ce07ca8af \
                    file://Documentation/licenses/COPYING.BSD-4-Clause-UC;md5=263860f8968d8bafa5392cab74285262 \
                    file://libuuid/COPYING;md5=6d2cafc999feb2c2de84d4d24b23290c \
                    file://libmount/COPYING;md5=7c7e39fb7d70ffe5d693a643e29987c2 \
                    file://libblkid/COPYING;md5=693bcbbe16d3a4a4b37bc906bc01cc04 \
                    file://libfdisk/COPYING;md5=693bcbbe16d3a4a4b37bc906bc01cc04 \
                    file://libsmartcols/COPYING;md5=693bcbbe16d3a4a4b37bc906bc01cc04 \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/util-linux:"
MAJOR_VERSION = "${@'.'.join(d.getVar('PV').split('.')[0:2])}"
SRC_URI = "file://util-linux/util-linux-${PV}.tar.xz \
           file://util-linux/2.36-login-lastlog-create.patch \
           file://util-linux/backport-CVE-2021-3995.patch \
           file://util-linux/backport-CVE-2021-3996.patch \
           file://util-linux/realloc-buffer-when-header-size-changed.patch \
           file://util-linux/fix-size-use-for-stdin.patch \
           file://util-linux/segmentation-fault-on-invalid-unicode-input-passed-to-s-option.patch \
           file://util-linux/backport-fix-by-ignoring-EINVAL-on-remount-of-proc.patch \
           file://util-linux/Add-check-to-resolve-uname26-version-test-failed.patch \
           file://util-linux/SKIPPED-no-root-permissions-test.patch \
	   file://runuser.pamd \
	   file://runuser-l.pamd \
	   "

SRC_URI[sha256sum] = "6a0764c1aae7fb607ef8a6dd2c0f6c47d5e5fd27aa08820abaad9ec14e28e9d9 "
