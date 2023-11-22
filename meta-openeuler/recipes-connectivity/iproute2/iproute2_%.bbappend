PV = "5.15.0"
OPENEULER_REPO_NAME = "iproute"

OPENEULER_SRC_URI_REMOVE = "https git http"

SRC_URI_remove = "\
    ${KERNELORG_MIRROR}/linux/utils/net/${BPN}/${BP}.tar.xz \
"

SRC_URI += " \
        file://${BPN}-${PV}.tar.xz \
        file://backport-bridge-Fix-memory-leak-when-doing-fdb-get.patch \
        file://backport-devlink-fix-devlink-health-dump-command-without-arg.patch \
        file://backport-ip-Fix-size_columns-for-very-large-values.patch \
        file://backport-ip-Fix-size_columns-invocation-that-passes-a-32-bit-.patch \
        file://backport-ip-address-Fix-memory-leak-when-specifying-device.patch \
        file://backport-ip-neigh-Fix-memory-leak-when-doing-get.patch \
        file://backport-ipmaddr-fix-dereference-of-NULL-on-malloc-failure.patch \
        file://backport-ipnetns-fix-fd-leak-with-ip-netns-set.patch \
        file://backport-iproute2-optimize-code-and-fix-some-mem-leak-risk.patch \
        file://backport-iproute_lwtunnel-fix-array-boundary-check.patch \
        file://backport-iproute_lwtunnel-fix-possible-use-of-NULL-when-mallo.patch \
        file://backport-iptunnel-detect-protocol-mismatch-on-tunnel-change.patch \
        file://backport-l2tp-fix-typo-in-AF_INET6-checksum-JSON-print.patch \
        file://backport-libnetlink-fix-socket-leak-in-rtnl_open_byproto.patch \
        file://backport-lnstat-fix-buffer-overflow-in-header-output.patch \
        file://backport-lnstat-fix-strdup-leak-in-w-argument-parsing.patch \
        file://backport-m_action-fix-warning-of-overwrite-of-const-string.patch \
        file://backport-mptcp-Fix-memory-leak-when-doing-endpoint-show.patch \
        file://backport-mptcp-Fix-memory-leak-when-getting-limits.patch \
        file://backport-netem-fix-NULL-deref-on-allocation-failure.patch \
        file://backport-nstat-fix-potential-NULL-deref.patch \
        file://backport-q_cake-allow-changing-to-diffserv3.patch \
        file://backport-rdma-utils-fix-some-analyzer-warnings.patch \
        file://backport-rt_names-check-for-malloc-failure.patch \
        file://backport-tc-em_u32-fix-offset-parsing.patch \
        file://backport-tc-flower-Fix-buffer-overflow-on-large-labels.patch \
        file://backport-tc-prio-handle-possible-truncated-kernel-response.patch \
        file://backport-tc_exec-don-t-dereference-NULL-on-calloc-failure.patch \
        file://backport-tc_util-Fix-parsing-action-control-with-space-and-sl.patch \
        file://backport-tc_util-fix-unitialized-warning.patch \
        file://backport-tipc-fix-keylen-check.patch \
        file://bugfix-iproute2-3.10.0-fix-maddr-show.patch \
        file://bugfix-iproute2-cancel-some-test-cases.patch \
        file://bugfix-iproute2-change-proc-to-ipnetnsproc-which-is-private.patch \
        file://feature-iproute-add-support-for-ipvlan-l2e-mode.patch \
" 
