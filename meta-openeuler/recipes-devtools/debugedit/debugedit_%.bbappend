PV = "5.0"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://tests-Handle-zero-directory-entry-in-.debug_line-DWA.patch \
        file://find-debuginfo.sh-decompress-DWARF-compressed-ELF-se.patch \
        file://tests-Ignore-stderr-output-of-readelf-in-debugedit.a.patch \
        file://backport-Fix-u-option.patch \
        file://add-loongarch-support-for-debugedit.patch \
"