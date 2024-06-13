OPENEULER_REPO_NAME = "libnl3"

OPENEULER_SRC_URI_REMOVE = "https"

# file and patches from openEuler
SRC_URI_prepend = "file://libnl-${PV}.tar.gz \
    file://backport-prevent-segfault-in-af_request_type.patch \
    file://backport-fix-bridge-info-parsing.patch \
    file://solve-redefinition-of-struct-ipv6_mreq.patch \
    file://backport-add-some-tests-about-addr-class-rule-neigh-qdisc.patch \
    file://backport-clear-XFRM_SP_ATTR_TMPL-when-removing-the-last-template.patch \
    file://backport-fix-reference-counters-of-sa-selector-addresses.patch \
    file://backport-do-not-use-static-array-indices-for-buffer.patch \
    file://backport-fix-leak-in-error-handling-of-rtnl_flower_append_action.patch \
    file://backport-fix-signed-overflow-warning-in-nl_object_diff.patch \
    file://backport-workaround-coverity-warning-about-time_t-handling.patch \
    file://backport-fix-leaking-usertemplate-in-xfrmnl_sp_parse.patch \
    file://backport-avoid-integer-overflow-in-rtnl_tc_calc_cell_log.patch \
    file://backport-fix-crashes-in-case-of-ENOMEM.patch \
    file://backport-accept-NULL-argument-in-nla_nest_cancel-for-robustness.patch \
    file://backport-fix-error-handling-in-nl_str2ip_protos.patch \
    file://backport-handle-negative-and-zero-size-in-nla_memcpy.patch \
    file://backport-use-thread-safe-gmtime_r-instead-of-gmtime.patch \
"

PV = "3.7.0"

SRC_URI[md5sum] = "b381405afd14e466e35d29a112480333"
SRC_URI[sha256sum] = "9fe43ccbeeea72c653bdcf8c93332583135cda46a79507bfd0a483bb57f65939"
