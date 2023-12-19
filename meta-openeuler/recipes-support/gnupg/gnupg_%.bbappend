PV = "2.2.32"

OPENEULER_REPO_NAME = "gnupg2"
SRC_URI_append = " \
        file://gnupg-${PV}.tar.bz2 \
        file://fix-a-memory-leak-in-g10.patch \
        file://gnupg-2.1.10-secmem.patch \
        file://gnupg-2.1.1-fips-algo.patch \
        file://gnupg-2.2.23-insttools.patch \
        file://gnupg-2.2.23-large-rsa.patch \
        file://gnupg-2.2.16-ocsp-keyusage.patch \
        file://gnupg-2.2.18-gpg-accept-subkeys-with-a-good-revocation-but-no-self-sig.patch \
        file://gnupg-2.2.18-gpg-allow-import-of-previously-known-keys-even-without-UI.patch \
        file://gnupg-2.2.18-tests-add-test-cases-for-import-without-uid.patch \
        file://gnupg-2.2.20-file-is-digest.patch \
        file://gnupg-2.2.21-coverity.patch \
        file://common-Avoid-undefined-behavior-of-left-shift-operat.patch \
        file://backport-CVE-2022-34903.patch \
        file://backport-common-Protect-against-a-theoretical-integer-overflow.patch \
"


SRC_URI[sha256sum] = "b2571b35f82c63e7d278aa6a1add0d73453dc14d3f0854be490c844fca7e0614"
