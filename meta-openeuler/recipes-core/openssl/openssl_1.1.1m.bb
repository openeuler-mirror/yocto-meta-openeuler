require openssl.inc
SUMMARY = "Secure Socket Layer"
DESCRIPTION = "Secure Socket Layer (SSL) binary and related cryptographic tools."
HOMEPAGE = "http://www.openssl.org/"
BUGTRACKER = "http://www.openssl.org/news/vulnerabilities.html"
SECTION = "libs/network"

# "openssl" here actually means both OpenSSL and SSLeay licenses apply
# (see meta/files/common-licenses/OpenSSL to which "openssl" is SPDXLICENSEMAPped)
LICENSE = "openssl"

DEPENDS = "hostperl-runtime-native"

inherit lib_package multilib_header
MULTILIB_SCRIPTS = "${PN}-bin:${bindir}/c_rehash"

PACKAGECONFIG ?= ""
PACKAGECONFIG_class-native = ""
PACKAGECONFIG_class-nativesdk = ""

PACKAGECONFIG[cryptodev-linux] = "enable-devcryptoeng,disable-devcryptoeng,cryptodev-linux"

#| ./libcrypto.so: undefined reference to `getcontext'
#| ./libcrypto.so: undefined reference to `setcontext'
#| ./libcrypto.so: undefined reference to `makecontext'
EXTRA_OECONF_append_libc-musl = " no-async"
EXTRA_OECONF_append_libc-musl_powerpc64 = " no-asm"

# This prevents openssl from using getrandom() which is not available on older glibc versions
# (native versions can be built with newer glibc, but then relocated onto a system with older glibc)
EXTRA_OECONF_class-native = "--with-rand-seed=devrandom"
EXTRA_OECONF_class-nativesdk = "--with-rand-seed=devrandom"

# Relying on hardcoded built-in paths causes openssl-native to not be relocateable from sstate.
CFLAGS_append_class-native = " -DOPENSSLDIR=/not/builtin -DENGINESDIR=/not/builtin"
CFLAGS_append_class-nativesdk = " -DOPENSSLDIR=/not/builtin -DENGINESDIR=/not/builtin"
CFLAGS_append += "${LDFLAGS}"

EXTRA_OECONF_arm32a15eb += " -no-asm"

do_configure () {
        os=${HOST_OS}
        case $os in
        linux-gnueabi |\
        linux-gnuspe |\
        linux-musleabi |\
        linux-muslspe |\
        linux-musl )
                os=linux
                ;;
        *)
                ;;
        esac
        target="$os-${HOST_ARCH}"
        case $target in
        linux-arm*)
                target=linux-armv4
                ;;
        linux-aarch64*)
                target=linux-aarch64
                ;;
        linux-i?86 | linux-viac3)
                target=linux-x86
                ;;
        linux-gnux32-x86_64 | linux-muslx32-x86_64 )
                target=linux-x32
                ;;
        linux-gnu64-x86_64)
                target=linux-x86_64
                ;;
        linux-mips | linux-mipsel)
                # specifying TARGET_CC_ARCH prevents openssl from (incorrectly) adding target architecture flags
                target="linux-mips32 ${TARGET_CC_ARCH}"
                ;;
        linux-gnun32-mips*)
                target=linux-mips64
                ;;
        linux-*-mips64 | linux-mips64 | linux-*-mips64el | linux-mips64el)
                target=linux64-mips64
                ;;
        linux-microblaze* | linux-nios2* | linux-sh3 | linux-sh4 | linux-arc*)
                target=linux-generic32
                ;;
        linux-powerpc)
                target=linux-ppc
                ;;
        linux-powerpc64)
                target=linux-ppc64
                ;;
        linux-riscv32)
                target=linux-generic32
                ;;
        linux-riscv64)
                target=linux-generic64
                ;;
        linux-sparc | linux-supersparc)
                target=linux-sparcv9
                ;;
        linux-gnu_ilp32*)
                target=linux-arm64ilp32
                ;;
        esac

        useprefix=${prefix}
        if [ "x$useprefix" = "x" ]; then
                useprefix=/
        fi
        # WARNING: do not set compiler/linker flags (-I/-D etc.) in EXTRA_OECONF, as they will fully replace the
        # environment variables set by bitbake. Adjust the environment variables instead.
        if [ target = "linux-arm64ilp32" ]; then
                perl ./Configure --prefix=$useprefix --openssldir=${libdir}/ssl-1.1 --libdir=${libdir} $target
        else
                perl ./Configure ${EXTRA_OECONF} ${PACKAGECONFIG_CONFARGS} --prefix=$useprefix --openssldir=${libdir}/ssl-1.1 --libdir=${libdir} $target
        fi

}

do_install () {
        oe_runmake DESTDIR="${D}" MANDIR="${mandir}" MANSUFFIX=ssl install

        oe_multilib_header openssl/opensslconf.h

        # Create SSL structure for packages such as ca-certificates which
        # contain hard-coded paths to /etc/ssl. Debian does the same.
        install -d ${D}${sysconfdir}/ssl
        mv ${D}${libdir}/ssl-1.1/certs \
           ${D}${libdir}/ssl-1.1/private \
           ${D}${libdir}/ssl-1.1/openssl.cnf \
           ${D}${sysconfdir}/ssl/

        # Although absolute symlinks would be OK for the target, they become
        # invalid if native or nativesdk are relocated from sstate.
        ln -sf ${@oe.path.relative('${libdir}/ssl-1.1', '${sysconfdir}/ssl/certs')} ${D}${libdir}/ssl-1.1/certs
        ln -sf ${@oe.path.relative('${libdir}/ssl-1.1', '${sysconfdir}/ssl/private')} ${D}${libdir}/ssl-1.1/private
        ln -sf ${@oe.path.relative('${libdir}/ssl-1.1', '${sysconfdir}/ssl/openssl.cnf')} ${D}${libdir}/ssl-1.1/openssl.cnf
}

do_install_append_class-native () {
        create_wrapper ${D}${bindir}/openssl \
            OPENSSL_CONF=${libdir}/ssl-1.1/openssl.cnf \
            SSL_CERT_DIR=${libdir}/ssl-1.1/certs \
            SSL_CERT_FILE=${libdir}/ssl-1.1/cert.pem \
            OPENSSL_ENGINES=${libdir}/ssl-1.1/engines
}

do_install_append_class-nativesdk () {
        mkdir -p ${D}${SDKPATHNATIVE}/environment-setup.d
        install -m 644 ${WORKDIR}/environment.d-openssl.sh ${D}${SDKPATHNATIVE}/environment-setup.d/openssl.sh
        sed 's|/usr/lib/ssl/|/usr/lib/ssl-1.1/|g' -i ${D}${SDKPATHNATIVE}/environment-setup.d/openssl.sh
}

# Add the openssl.cnf file to the openssl-conf package. Make the libcrypto
# package RRECOMMENDS on this package. This will enable the configuration
# file to be installed for both the openssl-bin package and the libcrypto
# package since the openssl-bin package depends on the libcrypto package.

FILES_libcrypto = "${libdir}/libcrypto${SOLIBS}"
FILES_libssl = "${libdir}/libssl${SOLIBS}"
FILES_openssl-conf = "${sysconfdir}/ssl/openssl.cnf"
FILES_${PN}-engines = "${libdir}/engines-1.1"
FILES_${PN}-misc = "${libdir}/ssl-1.1/misc"
FILES_${PN} += "${libdir}/ssl-1.1/* ${sysconfdir}/ssl/*"
FILES_${PN}_append_class-nativesdk = " ${SDKPATHNATIVE}/environment-setup.d/openssl.sh"
FILES_${PN} += "${libdir}/engines-1.1/*"

CONFFILES_openssl-conf = "${sysconfdir}/ssl/openssl.cnf"

RRECOMMENDS_libcrypto += "openssl-conf"
RDEPENDS_${PN}-ptest += "openssl-bin perl perl-modules bash"

# Remove bash dependencies for all image
RDEPENDS_${PN}-ptest_remove += "bash"

BBCLASSEXTEND = "native nativesdk"

CVE_PRODUCT = "openssl:openssl"

