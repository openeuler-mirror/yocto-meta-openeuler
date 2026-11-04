# main bbfile: yocto-poky/meta/recipes-devtools/strace/strace_5.16.bb

# strace version in openEuler (the src repo moved to 6.6 with a
# deadlock-fix backport series)
PV = "6.6"

LIC_FILES_CHKSUM = "file://COPYING;md5=63c8c3eb5c71b4362edac1397f40bdc7"

# remove conflict patch
SRC_URI:remove = " \
        file://Makefile-ptest.patch \
        file://skip-load.patch \
        file://0001-landlock-update-expected-string.patch \
"

SRC_URI:append = "file://${BP}.tar.xz \
        file://backport-0001-Fix-the-type-of-tcbtab-iterators.patch \
        file://backport-0002-Move-print_debug_info-definition-before-cleanup.patch \
        file://backport-0003-Factor-out-droptcb_verbose-from-detach.patch \
        file://backport-0004-Factor-out-interrupt_or_stop-from-detach.patch \
        file://backport-0005-Factor-out-detach_interrupted_or_stopped-from-detach.patch \
        file://backport-0006-strace-fix-potential-deadlock-during-cleanup.patch \
"

SRC_URI[md5sum] = "e1e791635e89113a78e889bfe070c111"
SRC_URI[sha256sum] = "421b4186c06b705163e64dc85f271ebdcf67660af8667283147d5e859fc8a96c"
