PV = "2.39.1"

# files, patches can't be applied in openeuler or conflict with openeuler
# ptest.patch, patch-fuzz warning
SRC_URI:remove = " \
        file://ptest.patch \
        file://avoid_parallel_tests.patch \
        file://Automake-use-EXTRA_LTLIBRARIES-instead-of-noinst_LTL.patch \
        file://CVE-2021-37600.patch \
"

# files, patches that come from openeuler
# not apply: util-linux-Add-sw64-architecture.patch
SRC_URI:prepend = " \
        file://util-linux-${PV}.tar.xz \
        file://2.36-login-lastlog-create.patch \
        file://backport-unshare-Move-implementation-of-keep-caps-option-to-l.patch \
        file://backport-lib-caputils-fix-integer-handling-issues-coverity-sc.patch \
        file://backport-fadvise-test-dynamically-calculate-expected-test-val.patch \
        file://backport-fadvise-tests-factor-out-calls-to-fincore.patch \
        file://backport-fadvise-test-don-t-compare-fincore-page-counts.patch \
        file://backport-fadvise-test-test-with-64k-blocks.patch \
        file://backport-tests-lsfd-mkfds-alter-the-L4-ports-for-avo.patch \
        file://SKIPPED-no-root-permissions-test.patch \
"

LICENSE = "GPL-2.0-or-later & LGPL-2.1-or-later & BSD-2-Clause & BSD-3-Clause & BSD-4-Clause"
LIC_FILES_CHKSUM = "file://README.licensing;md5=12ae7768a65ec8f2e44d930df9cb43fa \
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

SRC_URI[sha256sum] = "890ae8ff810247bd19e274df76e8371d202cda01ad277681b0ea88eeaa00286b"
