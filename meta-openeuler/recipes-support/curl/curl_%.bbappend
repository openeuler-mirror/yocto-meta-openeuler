# main bbfile: yocto-poky/meta/recipes-support/curl/curl_7.75.0.bb

# version in openEuler
PV = "7.86.0"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        https://curl.haxx.se/download/curl-${PV}.tar.bz2 \
        file://0001-vtls-add-isproxy-argument-to-Curl_ssl_get-addsession.patch \
        file://0002-transfer-strip-credentials-from-the-auto-referer-hea.patch \
        file://vtls-fix-addsessionid.patch \
        file://vtls-fix-warning.patch \
        file://CVE-2021-22898.patch \
        file://CVE-2021-22897.patch \
        file://CVE-2021-22925.patch \
        file://CVE-2021-22901.patch \
        file://CVE-2021-22924.patch \
        file://CVE-2021-22926.patch \
        file://CVE-2021-22945.patch \
        file://CVE-2021-22946.patch \
        file://CVE-2021-22947.patch \
"

# files, patches that come from openeuler
# do not apply backport-0101-curl-7.32.0-multilib.patch due to failure "libcurl.pc failed sanity test" when doing QA staging "pkg-config libcurl" in this patch
SRC_URI += " \
        file://${BP}.tar.xz \
        file://backport-curl-7.84.0-test3026.patch \
        file://backport-CVE-2022-43551-http-use-the-IDN-decoded-name-in-HSTS-checks.patch \
        file://backport-CVE-2022-43552-smb-telnet-do-not-free-the-protocol-struct-in-_done.patch \
        file://backport-0001-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0002-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0003-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0004-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0005-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0006-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-CVE-2023-23916.patch \
"      

SRC_URI[md5sum] = "19a2165f37941a6f412afc924e750568"
SRC_URI[sha256sum] = "2d61116e5f485581f6d59865377df4463f2e788677ac43222b496d4e49fb627b"

LIC_FILES_CHKSUM = "file://COPYING;md5=190c514872597083303371684954f238"

# the version 7.86.0 in install function add a sed command
do_install_append_class-target() {
	# cleanup buildpaths from curl-config
	sed -i \
	    -e 's|${@" ".join(d.getVar("DEBUG_PREFIX_MAP").split())}||g' \
	    ${D}${bindir}/curl-config
}

# configure.ac in openEuler can't handle --without-libmetalink variable
EXTRA_OECONF_remove = " \
        --without-libmetalink \
"

# the version 7.86.0 packageconfig add libgsasl, openssl, zstd param and remove ssl param
PACKAGECONFIG[libgsasl] = "--with-libgsasl,--without-libgsasl,libgsasl"
PACKAGECONFIG[openssl] = "--with-openssl,--without-openssl,openssl"
PACKAGECONFIG[ssl] = ""
PACKAGECONFIG[zstd] = "--with-zstd,--without-zstd,zstd"

EXTRA_OECONF_append = " \
    ${@'--without-ssl' if (bb.utils.filter('PACKAGECONFIG', 'gnutls mbedtls nss openssl', d) == '') else ''} \
"

# It is not safe to pack crt files in rootfs by default, if you sure what you want, comment these lines:
EXTRA_OECONF_remove += " \
        --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
        --without-libmetalink \
"
RRECOMMENDS_lib${BPN}_remove += "ca-certificates"
