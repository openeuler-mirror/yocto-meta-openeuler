PV = "1.8.7"


OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI += "file://${BPN}-${PV}.tar.bz2 \
            file://bugfix-add-check-fw-in-entry.patch \
            file://tests-extensions-add-some-testcases.patch \
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
            "      

SRC_URI[sha256sum] = "ef6639a43be8325a4f8ea68123ffac236cb696e8c78501b64e8106afb008c87f"
