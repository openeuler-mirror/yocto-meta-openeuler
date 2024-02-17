PV = "2.4.3"

OPENEULER_REPO_NAME = "gnupg2"

SRC_URI:append = " \
        file://${BP}.tar.bz2 \
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
        "
