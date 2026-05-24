# main bb file from: meta/recipes-connectivity/openssl/openssl_3.2.3.bb

# openEuler version
PV = "3.5.6"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# remove scarthgap patches that conflict with openEuler 3.5.6 tarball
# NOTE: 0001-buildinfo-strip-sysroot-and-debug-prefix-map-from-co.patch uses
# -fcanon-prefix-map which requires GCC 13+; our external toolchain is GCC 12.3.1
SRC_URI:remove = "file://0001-buildinfo-strip-sysroot-and-debug-prefix-map-from-co.patch         file://0001-Configure-do-not-tweak-mips-cflags.patch         file://0001-Added-handshake-history-reporting-when-test-fails.patch         file://0001-extend-check_cwm-test-timeout.patch "

EXTRA_OECONF:append = " enable-sm2 enable-sm4"

# patches in openEuler 3.5.6
# add-FIPS_mode_set-support.patch: already incorporated in openssl 3.5.6
SRC_URI:prepend = "file://${BP}.tar.gz         file://openssl-3.5-build.patch         file://Feature-support-SM2-CMS-signature.patch         file://Feature-use-default-id-if-SM2-id-is-not-set.patch         file://backport-Add-FIPS_mode-compatibility-macro.patch         file://Fix-build-error-for-ppc64le.patch         file://add-support-for-sw_64-architecture.patch         file://fix-add-loongarch64-target.patch "

# use openeuler style ssl env setup file
SRC_URI:append:class-nativesdk = "            file://environment.d-openeuler-openssl.sh            "

do_install:append () {
        #Remove the empty directory that conflict with ca-certificates.
        rm -rf ${D}${sysconfdir}/ssl/certs
}

do_install:append:class-nativesdk () {
        # override poky ssl env setup file
        rm -f ${D}${SDKPATHNATIVE}/environment-setup.d/openssl.sh
        install -m 644 ${WORKDIR}/environment.d-openeuler-openssl.sh ${D}${SDKPATHNATIVE}/environment-setup.d/openssl.sh
}

ASSUME_PROVIDE_PKGS ="openssl openssl-libs"

# buildpath strip patch (0001-buildinfo-strip-sysroot-and-debug-prefix-map-from-co.patch) was
# removed above because it requires -fcanon-prefix-map (GCC 14+); suppress QA warning instead
INSANE_SKIP:libcrypto += "buildpaths"
INSANE_SKIP:openssl-staticdev += "buildpaths"
