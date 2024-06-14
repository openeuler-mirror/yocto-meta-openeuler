PV = "1.8.7"


OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI += "file://${BPN}-${PV}.tar.bz2 \
            file://bugfix-add-check-fw-in-entry.patch \
            file://tests-extensions-add-some-testcases.patch \
            file://backport-libxtables-Fix-memleak-in-xtopt_parse_hostmask.patch \
            file://backport-nft-Avoid-memleak-in-error-path-of-nft_cmd_new.patch \
            file://backport-exit-if-called-by-setuid-executeable.patch \
            file://backport-fix-for-non-verbose-check-command.patch \
            file://backport-use-fully-random-so-that-nft-can-understand.patch \
            file://backport-nft-Use-xtables_malloc-in-mnl_err_list_node_add.patch \
            file://backport-xshared-Fix-response-to-unprivileged-users.patch \
            file://backport-Improve-error-messages-for-unsupported-extensions.patch \
            file://backport-nft-Fix-EPERM-handling-for-extensions-without-rev-0.patch \
            file://backport-libxtables-Register-only-the-highest-revision-extension.patch \
            file://backport-nft-Expand-extended-error-reporting-to-nft_cmd-too.patch \
            file://backport-xtables-restore-Extend-failure-error-message.patch \
            file://enabled-makecheck-in-extensions.patch \
            file://backport-extensions-among-Fix-for-use-with-ebtables-restore.patch \
            file://backport-extensions-libebt_redirect-Fix-xlate-return-code.patch \
            file://backport-extensions-libipt_ttl-Sanitize-xlate-callback.patch \
            file://backport-iptables-restore-Free-handle-with-test-also.patch \
            file://backport-nft-Plug-memleak-in-nft_rule_zero_counters.patch \
            file://backport-iptables-Plug-memleaks-in-print_firewall.patch \
            file://backport-ebtables-translate-Print-flush-command-after-parsing-is-finished.patch \
            file://backport-xtables-eb-fix-crash-when-opts-isn-t-reallocated.patch \
            file://backport-iptables-Fix-handling-of-non-existent-chains.patch \
            file://backport-Special-casing-for-among-match-in-compare_matches.patch \
            file://backport-libipt_icmp-Fix-confusion-between-255-and-any.patch \
            file://backport-fix-wrong-maptype-of-base-chain-counters-on-restore.patch \
            file://backport-Fix-checking-of-conntrack-ctproto.patch \
            file://backport-Fix-for-non-CIDR-compatible-hostmasks.patch \
            file://backport-Prevent-XTOPT_PUT-with-XTTYPE_HOSTMASK.patch \
            file://backport-libiptc-Fix-for-segfault-when-renaming-a-chain.patch \
            file://backport-libiptc-Fix-for-another-segfault-due-to-chain-index-NULL-pointer.patch \
            "      

SRC_URI[sha256sum] = "ef6639a43be8325a4f8ea68123ffac236cb696e8c78501b64e8106afb008c87f"
