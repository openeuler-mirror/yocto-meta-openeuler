PV = "4.9.3"
require pypi-src-openeuler.inc

SRC_URI:remove = "file://CVE-2022-2309.patch"

# apply openeuler's patches
SRC_URI:append = " \
        file://Make-the-validation-of-ISO-Schematron-files-optional.patch \
        file://380.patch \
        file://Skip-failing-test_iterparse_utf16_bom.patch \
        file://backport-Change-HTML-prefix-handling-in-ElementPath-to-let-el.patch \
        "
