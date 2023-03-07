PV = "1.8.9"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI += "file://${BPN}-${PV}.tar.xz \
            file://0001-extensions-NAT-Fix-for-Werror-format-security.patch \
            "

SRC_URI[sha256sum] = "ef6639a43be8325a4f8ea68123ffac236cb696e8c78501b64e8106afb008c87f"

# For iptables-1.8.9, the following files need to be added to FILES_${PN}
FILES_${PN}-module-xt-ct += "${libdir}/xtables/libxt_REDIRECT.so ${libdir}/xtables/libxt_MASQUERADE.so ${libdir}/xtables/libxt_DNAT.so ${libdir}/xtables/libxt_SNAT.so"
