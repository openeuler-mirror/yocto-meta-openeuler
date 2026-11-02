PV = "2.4.3"

OPENEULER_LOCAL_NAME = "gnupg2"

SRC_URI:append = " \
        file://backport-dirmngr-Enable-the-call-of-ks_ldap_help_variables-wh.patch \
        file://gnupg-2.1.10-secmem.patch \
        file://gnupg-2.1.1-fips-algo.patch \
        file://gnupg-2.2.18-gpg-accept-subkeys-with-a-good-revocation-but-no-self-sig.patch \
        file://gnupg-2.2.18-gpg-allow-import-of-previously-known-keys-even-without-UI.patch \
        file://gnupg-2.2.18-tests-add-test-cases-for-import-without-uid.patch \
        file://gnupg-2.2.20-file-is-digest.patch \
        file://gnupg-2.2.21-coverity.patch \
        file://gnupg-2.2.23-large-rsa.patch \
        file://gnupg2-revert-rfc4880bis.patch \
        file://gnupg-2.1.10-secmem.patch \
        file://gnupg-2.1.1-fips-algo.patch \
        file://gnupg-2.2.23-large-rsa.patch \
        file://gnupg-2.2.18-gpg-accept-subkeys-with-a-good-revocation-but-no-self-sig.patch \
        file://gnupg-2.2.18-gpg-allow-import-of-previously-known-keys-even-without-UI.patch \
        file://gnupg-2.2.18-tests-add-test-cases-for-import-without-uid.patch \
        file://gnupg-2.2.20-file-is-digest.patch \
        file://gnupg-2.2.21-coverity.patch \
        file://gnupg2-revert-rfc4880bis.patch \
        file://backport-dirmngr-Enable-the-call-of-ks_ldap_help_variables-wh.patch \
        file://backport-gpg-Make-no-literal-work-again-for-c-and-store.patch \
        file://backport-gpg-Fix-minor-memory-leak-during-certain-smartcard-o.patch \
        file://supports-sm2-algorithm-signature-and-uses-sm3-hash-algorithm.patch \
        file://backport-0001-CVE-2025-30258.patch \
        file://backport-0002-CVE-2025-30258.patch \
        file://backport-0003-CVE-2025-30258.patch \
        file://backport-0004-CVE-2025-30258.patch \
        file://backport-0005-CVE-2025-30258.patch \
        file://backport-0006-CVE-2025-30258.patch \
        file://backport-gpg-Fix-double-free-of-internal-data.patch \
        file://backport-common-Fix-read-buffer-over-read-in-uncompress_ecc_q.patch \
        file://backport-gpg-Avoid-potential-downgrade-to-SHA1-in-3rd-party-k.patch \
        file://backport-CVE-2025-68973.patch \
        file://backport-CVE-2026-24882.patch \
        file://backport-CVE-2026-24882-agent-Fix-the-regression-in-pkdecrypt-with-TPM-RSA.patch \
        file://backport-CVE-2026-57062.patch \
        file://backport-common-Fix-composite-DO-parsing.patch \
        file://backport-CVE-2026-105712-1.patch \
        file://backport-CVE-2026-105712-2.patch \
        file://backport-CVE-2026-105712-3.patch \
        file://backport-CVE-2026-105712-4.patch \
"
