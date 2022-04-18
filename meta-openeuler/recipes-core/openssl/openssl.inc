DEPENDS = "perl-native-runtime nettle"

SRC_URI = "file://openssl/${BP}.tar.gz \
           file://openssl/openssl-1.1.1-build.patch \
           file://openssl/openssl-1.1.1-fips.patch \
	   file://0001-buildinfo-strip-sysroot-and-debug-prefix-map-from-co.patch \
	   file://0001-skip-test_symbol_presence.patch \
	   file://0003-Add-support-for-io_pgetevents_time64-syscall.patch \
	   file://0004-Fixup-support-for-io_pgetevents_time64-syscall.patch \
	   file://afalg.patch \
	   file://reproducible.patch \
"

LIC_FILES_CHKSUM = "file://LICENSE;md5=d343e62fc9c833710bbbed25f27364c8"

S = "${WORKDIR}/${BP}"

#AR_append = " r"
# Avoid binaries being marked as requiring an executable stack since it
# doesn't(which causes and this causes issues with SELinux
inherit utils
CFLAG = "${@oe.utils.conditional('SITEINFO_ENDIANNESS', 'le', '-DL_ENDIAN', '-DB_ENDIAN', d)} \
 -DTERMIO ${CFLAGS} -Wall -Wa,--noexecstack"

# -02 does not work on mipsel: ssh hangs when it tries to read /dev/urandom
CFLAG_mtx-1 := "${@'${CFLAG}'.replace('-O2', '')}"
CFLAG_mtx-2 := "${@'${CFLAG}'.replace('-O2', '')}"

export DIRS = "crypto ssl apps"
export EX_LIBS = "-lgcc -ldl"
export AS = "${CC} -c"

inherit pkgconfig siteinfo ptest

# Remove this to enable SSLv3. SSLv3 is defaulted to disabled due to the POODLE
# vulnerability
EXTRA_OECONF = " -no-ssl3"

do_configure_prepend_darwin () {
 sed -i -e '/version-script=openssl\.ld/d' Configure
}

do_compile_prepend_class-target () {
    sed -i 's/\((OPENSSL=\)".*"/\1"openssl"/' Makefile
}

do_compile () {
 oe_runmake
}

do_compile_ptest () {
 oe_runmake buildtest
}

do_install_ptest () {
 cp -r Makefile test ${D}${PTEST_PATH}
 cp -r certs ${D}${PTEST_PATH}
 mkdir -p ${D}${PTEST_PATH}/apps
 ln -sf /usr/lib/ssl/misc/CA.sh  ${D}${PTEST_PATH}/apps
 ln -sf /usr/lib/ssl/openssl.cnf ${D}${PTEST_PATH}/apps
 ln -sf /usr/bin/openssl         ${D}${PTEST_PATH}/apps
 cp apps/server2.pem             ${D}${PTEST_PATH}/apps
 mkdir -p ${D}${PTEST_PATH}/util
 install util/opensslwrap.sh    ${D}${PTEST_PATH}/util
 install util/shlib_wrap.sh     ${D}${PTEST_PATH}/util
}

do_install_append_virtclass-native() {
 create_wrapper ${D}${bindir}/openssl \
     OPENSSL_CONF=${libdir}/ssl/openssl.cnf \
     SSL_CERT_DIR=${libdir}/ssl/certs \
     SSL_CERT_FILE=${libdir}/ssl/cert.pem \
     OPENSSL_ENGINES=${libdir}/ssl/engines
}

BBCLASSEXTEND = "native nativesdk"
