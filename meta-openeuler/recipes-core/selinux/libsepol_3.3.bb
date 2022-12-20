require selinux_common.inc
require ${BPN}.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=a6f89e2100d9b6cdffcea4f398e37343"

SRC_URI += "file://libsepol/${BP}.tar.gz \
        file://backport-libsepol-add-missing-oom-checks.patch;striplevel=2 \
        file://backport-libsepol-check-correct-pointer-for-oom.patch;striplevel=2 \
        file://backport-libsepol-avoid-potential-NULL-dereference-on-optional-parameter.patch;striplevel=2 \
        file://backport-libsepol-do-not-modify-policy-during-write.patch;striplevel=2 \
        file://backport-libsepol-enclose-macro-parameters-and-replacement-lists-in-parentheses.patch;striplevel=2 \
        file://backport-libsepol-rename-validate_policydb-to-policydb_validate.patch;striplevel=2 \
        file://backport-libsepol-fix-missing-double-quotes-in-typetransition-CIL-rule.patch;striplevel=2 \
        "

CFLAGS +=  "${@bb.utils.contains('RTOS_KASAN', 'kasan', '-fcommon', '', d)}"
