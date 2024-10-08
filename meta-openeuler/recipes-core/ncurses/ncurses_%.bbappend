PV = "6.4"
CVE_VERSION = "${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
# CVE-2021-39537.patch from poky is for 6.2 and no need for openeuler 6.3 version
SRC_URI:remove = " \
            file://0002-configure-reproducible.patch \
            file://0003-gen-pkgconfig.in-Do-not-include-LDFLAGS-in-generated.patch \
            file://CVE-2021-39537.patch \
"

# files, patches that come from openeuler
SRC_URI += "file://${BP}.tar.gz \
           file://ncurses-config.patch \
           file://ncurses-libs.patch \
           file://ncurses-urxvt.patch \
           file://ncurses-kbs.patch \
           file://backport-0001-CVE-2023-29491-fix-configure-root-args-option.patch \
           file://backport-0002-CVE-2023-29491-env-access.patch \
           file://backport-fix-for-out-of-memory-condition.patch \
           file://backport-fix-coredump-when-use-Memmove.patch \
           file://backport-CVE-2023-50495.patch \
           file://backport-CVE-2023-45918.patch \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
# from oe-core
SRC_URI += "\
           file://exit_prototype.patch \
"

S = "${WORKDIR}/${BP}"
