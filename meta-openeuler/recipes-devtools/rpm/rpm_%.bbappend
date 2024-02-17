PV = "4.18.1"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# fix-declaration.patch same as backport-Fix-compiler-error-on-clang.patch in openeuler
SRC_URI:remove = " \
        file://fix-declaration.patch \
"

# files, patches that come from openeuler
# these patches not apply for unsupport arch:
#  rpm-Add-sw64-architecture.patch
#  Add-loongarch-architecture-support.patch 
#  add-default-machine-name-to-support-loongarch.patch 
SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://Unbundle-config-site-and-add-RPM-LD-FLAGS-macro.patch \
        file://rpm-4.12.0-rpm2cpio-hack.patch \
        file://add-dist-to-release-by-default.patch \
        file://revert-always-execute-file-trigger-scriptlet-callbac.patch \
        file://bugfix-rpm-4.11.3-add-aarch64_ilp32-arch.patch \
        file://bugfix-rpm-4.14.2-wait-once-get-rpmlock-fail.patch \
        file://get-in-use-of-ndb.patch \
        file://still-in-use-of-python-scripts-from-old-version.patch \
        file://backport-Fix-compiler-error-on-clang.patch \
        file://backport-Move-variable-to-nearest-available-scope.patch \
        file://backport-revert-Permit-building-rpm-from-git-without-pandoc.patch \
        file://backport-Fix-per-file-plugin-hook-regression-introduced-in-4..patch \
        file://backport-Remove-obscure-check-for-package-build-time-from-reb.patch \
        file://backport-Fix-possible-null-pointer-reference-in-ndb.patch \
        file://backport-Fix-rpmDigestBundleFinal-and-Update-return-code-on-i.patch \
        file://backport-Actually-return-an-error-in-parseScript-if-parsing-f.patch \
        file://Add-digest-list-plugin.patch \
        file://Add-IMA-digest-list-support.patch \
        file://backport-Check-inside-root-when-querying-for-files.patch \
"

SRC_URI[sha256sum] = "2e0d220b24749b17810ed181ac1ed005a56bbb6bc8ac429c21f314068dc65e6a"


# openeuler configuration
PACKAGECONFIG:append = " ndb"
