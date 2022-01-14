SUMMARY = "Command line tool and library for client-side URL transfers"
HOMEPAGE = "http://curl.haxx.se/"
BUGTRACKER = "http://curl.haxx.se/mail/list.cgi?list=curl-tracker"
SECTION = "console/network"
LICENSE = "MIT"


LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://curl/curl-7.77.0.tar.xz \
          file://curl/0101-curl-7.32.0-multilib.patch \
          file://curl/0102-curl-7.36.0-debug.patch \
          file://curl/0105-curl-7.63.0-lib1560-valgrind.patch \
          file://curl/0106-curl-fix-CVE-2019-15601.patch \
          file://curl/backport-CVE-2021-22925.patch \
          file://curl/backport-CVE-2021-22926.patch \
          "

S = "${WORKDIR}/${BPN}-${PV}"

CVE_PRODUCT = "curl libcurl"
inherit autotools

# Because UI console is removed from vpp's libopenssl, arm64le-preempt-pro does not support OPENSSL UI.

#PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} proxy ssl threaded-resolver verbose zlib"
PACKAGECONFIG_class-native = "ipv6 proxy ssl threaded-resolver verbose zlib"
PACKAGECONFIG_class-nativesdk = "ipv6 proxy ssl threaded-resolver verbose zlib"

# 'ares' and 'threaded-resolver' are mutually exclusive
PACKAGECONFIG[ares] = "--enable-ares,--disable-ares,c-ares"
PACKAGECONFIG[brotli] = "--with-brotli,--without-brotli,brotli"
PACKAGECONFIG[builtinmanual] = "--enable-manual,--disable-manual"
PACKAGECONFIG[dict] = "--enable-dict,--disable-dict,"
PACKAGECONFIG[gnutls] = "--with-gnutls,--without-gnutls,gnutls"
PACKAGECONFIG[gopher] = "--enable-gopher,--disable-gopher,"
PACKAGECONFIG[imap] = "--enable-imap,--disable-imap,"
PACKAGECONFIG[ipv6] = "--enable-ipv6,--disable-ipv6,"
PACKAGECONFIG[krb5] = "--with-gssapi,--without-gssapi,krb5"
PACKAGECONFIG[ldap] = "--enable-ldap,--disable-ldap,"
PACKAGECONFIG[ldaps] = "--enable-ldaps,--disable-ldaps,"
PACKAGECONFIG[libidn] = "--with-libidn2,--without-libidn2,libidn2"
PACKAGECONFIG[libssh2] = "--with-libssh2,--without-libssh2,libssh2"
PACKAGECONFIG[mbedtls] = "--with-mbedtls=${STAGING_DIR_TARGET},--without-mbedtls,mbedtls"
PACKAGECONFIG[nghttp2] = "--with-nghttp2,--without-nghttp2,nghttp2"
PACKAGECONFIG[pop3] = "--enable-pop3,--disable-pop3,"
PACKAGECONFIG[proxy] = "--enable-proxy,--disable-proxy,"
PACKAGECONFIG[rtmpdump] = "--with-librtmp,--without-librtmp,rtmpdump"
PACKAGECONFIG[rtsp] = "--enable-rtsp,--disable-rtsp,"
PACKAGECONFIG[smb] = "--enable-smb,--disable-smb,"
PACKAGECONFIG[smtp] = "--enable-smtp,--disable-smtp,"
PACKAGECONFIG[ssl] = "--with-ssl --with-random=/dev/urandom,--without-ssl,openssl"
PACKAGECONFIG[nss] = "--with-nss,--without-nss,nss"
PACKAGECONFIG[telnet] = "--enable-telnet,--disable-telnet,"
PACKAGECONFIG[tftp] = "--enable-tftp,--disable-tftp,"
PACKAGECONFIG[threaded-resolver] = "--enable-threaded-resolver,--disable-threaded-resolver"
PACKAGECONFIG[verbose] = "--enable-verbose,--disable-verbose"
PACKAGECONFIG[zlib] = "--with-zlib=${STAGING_LIBDIR}/../,--without-zlib,zlib"

EXTRA_OECONF = " \
    --disable-libcurl-option \
    --disable-ntlm-wb \
    --enable-crypto-auth \
    --without-libpsl \
"

do_install_append_class-target() {
    # cleanup buildpaths from curl-config
    sed -i \
        -e 's,--sysroot=${STAGING_DIR_TARGET},,g' \
        -e 's,--with-libtool-sysroot=${STAGING_DIR_TARGET},,g' \
        -e 's|${DEBUG_PREFIX_MAP}||g' \
        ${D}${bindir}/curl-config
}

PACKAGES =+ "lib${BPN}"

FILES_lib${BPN} = "${libdir}/lib*.so.*"

FILES_${PN} += "${datadir}/zsh"

#inherit multilib_script
#MULTILIB_SCRIPTS = "${PN}-dev:${bindir}/curl-config"

BBCLASSEXTEND = "native nativesdk"
