PV = "4.18.2"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# fix-declaration.patch same as backport-Fix-compiler-error-on-clang.patch in openeuler
# ea3187cfcf9cac87e5bc5e7db79b0338da9e355e has merged in new version
SRC_URI:remove = " \
        file://fix-declaration.patch \
        file://ea3187cfcf9cac87e5bc5e7db79b0338da9e355e.patch \
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
        file://backport-revert-Permit-building-rpm-from-git-without-pandoc.patch \
        file://backport-Check-inside-root-when-querying-for-files.patch \
        file://backport-Use-unsigned-integers-for-buildtime-too-for-Y2K38-sa.patch \
        file://backport-Fix-a-theoretical-use-of-uninitialized-struct-member.patch \
        file://backport-Fix-spec-parser-leaks-from-trans-f-file.patch \
        file://backport-Tip-toe-around-rpmfiFN-thin-ice-in-fsm.patch \
        file://backport-Fix-a-memleak-on-invalid-command-line-options.patch \
        file://backport-Let-eBPF-ELF-files-be-packaged-in-noarch-packages.patch \
        file://Add-digest-list-plugin.patch \
        file://Add-IMA-digest-list-support.patch \
"

SRC_URI[sha256sum] = "2e0d220b24749b17810ed181ac1ed005a56bbb6bc8ac429c21f314068dc65e6a"


# openeuler configuration
PACKAGECONFIG:append = " ndb"
