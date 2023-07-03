# main bbfile: yocto-poky/meta/recipes-connectivity/ppp/ppp_2.4.9.bb
PV = "2.4.9"

# source and patches from openeuler
# can't apply: backport-ppp-2.4.9-config.patch, no support new feature(pam,cbcp) here
# this patch backport-0011-build-sys-don-t-put-connect-errors-log-to-etc-ppp.patch make a new path and will conflict with other package, not apply
# failed to apply the patch： backport-0027-Set-LIBDIR-for-RISCV.patch (for riscv64)
SRC_URI:prepend = " \
        file://backport-0004-doc-add-configuration-samples.patch \
        file://backport-ppp-2.4.9-build-sys-don-t-hardcode-LIBDIR-but-set-it-according.patch \
        file://backport-0006-scritps-use-change_resolv_conf-function.patch \
        file://backport-ppp-2.4.8-pppd-we-don-t-want-to-accidentally-leak-fds.patch \
        file://backport-ppp-2.4.9-everywhere-O_CLOEXEC-harder.patch \
        file://backport-0014-everywhere-use-SOCK_CLOEXEC-when-creating-socket.patch \
        file://backport-0015-pppd-move-pppd-database-to-var-run-ppp.patch \
        file://backport-0016-rp-pppoe-add-manpage-for-pppoe-discovery.patch \
        file://backport-0018-scritps-fix-ip-up.local-sample.patch \
        file://backport-0020-pppd-put-lock-files-in-var-lock-ppp.patch \
        file://backport-0023-build-sys-install-rp-pppoe-plugin-files-with-standar.patch \
        file://backport-0024-build-sys-install-pppoatm-plugin-files-with-standard.patch \
        file://backport-ppp-2.4.8-pppd-install-pppd-binary-using-standard-perms-755.patch \
        file://backport-ppp-2.4.9-configure-cflags-allow-commas.patch \
        file://backport-pppd-Negotiate-IP-address-when-only-peer-addresses-are-provided.patch \
        file://backport-CVE-2022-4603.patch \
"

SRC_URI[sha256sum] = "f938b35eccde533ea800b15a7445b2f1137da7f88e32a16898d02dee8adc058d"
