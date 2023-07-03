PV = "2.3.6"

OPENEULER_REPO_NAME = "gnupg2"
SRC_URI = " \
        https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-${PV}.tar.bz2 \
        file://gnupg-2.1.10-secmem.patch \
        file://gnupg-2.1.1-fips-algo.patch \
        file://gnupg-2.2.23-large-rsa.patch \
        file://gnupg-2.2.16-ocsp-keyusage.patch \
        file://gnupg-2.2.18-gpg-accept-subkeys-with-a-good-revocation-but-no-self-sig.patch \
        file://gnupg-2.2.18-gpg-allow-import-of-previously-known-keys-even-without-UI.patch \
        file://gnupg-2.2.18-tests-add-test-cases-for-import-without-uid.patch \
        file://gnupg-2.2.20-file-is-digest.patch \
        file://gnupg-2.2.21-coverity.patch \
        file://backport-CVE-2022-34903.patch \
        "

# apply patches from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://0002-use-pkgconfig-instead-of-npth-config.patch \
           file://0004-autogen.sh-fix-find-version-for-beta-checking.patch \
           file://0001-Woverride-init-is-not-needed-with-gcc-9.patch \
           "
SRC_URI:append:class-native = " file://0001-configure.ac-use-a-custom-value-for-the-location-of-.patch \
                                file://relocate.patch"
SRC_URI:append:class-nativesdk = " file://relocate.patch"


SRC_URI[sha256sum] = "21f7fe2fc5c2f214184ab050977ec7a8e304e58bfae2ab098fec69f8fabda9c1"
