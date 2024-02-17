# main bbfile: yocto-poky/meta/recipes-extended/gawk/gawk_5.1.0.bb

# version in openEuler
PV = "5.2.0"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            file://remove-sensitive-tests.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
           file://${BP}.tar.xz \
           file://pma.patch \
           file://Disable-pma-test.awk.patch \
           file://backport-Fix-a-bug-with-Node_elem_new.patch \
           file://backport-Additional-fix-for-Node_elem_new.patch \
           file://backport-Yet-another-fix-and-test-for-Node_elem_new.patch \
           file://backport-Fix-a-memory-leak.patch \
           file://backport-Code-simplification-in-interpret.h.patch \
           file://backport-Fix-negative-NaN-issue-on-RiscV.patch \
           "

SRC_URI[md5sum] = "2f724d925873fc82f5e7b1d605ba9a42"
SRC_URI[sha256sum] = "e4ddbad1c2ef10e8e815ca80208d0162d4c983e6cca16f925e8418632d639018"
