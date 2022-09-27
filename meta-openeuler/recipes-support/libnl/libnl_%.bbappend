OPENEULER_REPO_NAME = "libnl3"
SRC_URI += " \
    file://backport-lib-add-include-netlink-private-nl-auto-h-header.patch \
    file://backport-lib-use-proper-int-type-for-id-attributes-in-nl_object_identical.patch \
    file://backport-route-link-add-RTNL_LINK_REASM_OVERLAPS-stat.patch \
    file://backport-route-link-Check-for-null-pointer-in-macvlan.patch \
    file://backport-rtnl-link-fix-leaking-rtnl_link_af_ops-in-link_msg_parser.patch \
    file://backport-rtnl-route-fix-NLE_NOMEM-handling-in-parse_multipath.patch \
    file://solve-redefinition-of-struct-ipv6_mreq.patch \
    file://add-a-test-test-add-route.patch \
    file://add-some-tests-about-addr-class-rule-neigh-qdisc.patch \
    file://backport-fix-setting-ce_mask-when-parsing-VF-stat-counter.patch \
    file://backport-allow-constructing-all-zero-addresses.patch \
"
