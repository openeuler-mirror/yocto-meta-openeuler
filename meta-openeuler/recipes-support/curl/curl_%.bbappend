# main bbfile: yocto-poky/meta/recipes-support/curl/curl_7.75.0.bb

# version in openEuler
PV = "7.86.0"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
           https://curl.se/download/${BP}.tar.xz \
           file://CVE-2022-22576.patch \
           file://CVE-2022-27775.patch \
           file://CVE-2022-27776.patch \
           file://CVE-2022-27774-1.patch \
           file://CVE-2022-27774-2.patch \
           file://CVE-2022-27774-3.patch \
           file://CVE-2022-27774-4.patch \
           file://CVE-2022-30115.patch \
           file://CVE-2022-27780.patch \
           file://CVE-2022-27781.patch \
           file://CVE-2022-27779.patch \
           file://CVE-2022-27782-1.patch \
           file://CVE-2022-27782-2.patch \
           file://0001-openssl-fix-CN-check-error-code.patch \
           file://CVE-2022-32205.patch \
           file://CVE-2022-32206.patch \
           file://CVE-2022-32207.patch \
           file://CVE-2022-32208.patch \
           file://CVE-2022-35252.patch \
           file://CVE-2022-32221.patch \
           file://CVE-2022-42916.patch \
           file://CVE-2022-42915.patch \
           file://CVE-2022-43551.patch \
           file://CVE-2022-43552.patch \
           file://CVE-2023-23914_5-1.patch \
           file://CVE-2023-23914_5-2.patch \
           file://CVE-2023-23914_5-3.patch \
           file://CVE-2023-23914_5-4.patch \
           file://CVE-2023-23914_5-5.patch \
           file://CVE-2023-23916.patch \
           file://CVE-2023-27533.patch \
           file://CVE-2023-27534.patch \
           file://CVE-2023-27535-pre1.patch \
           file://CVE-2023-27535_and_CVE-2023-27538.patch \
           file://CVE-2023-27536.patch \
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
do_install:append:class-target() {
	# cleanup buildpaths from curl-config
	sed -i \
	    -e 's|${@" ".join(d.getVar("DEBUG_PREFIX_MAP").split())}||g' \
	    ${D}${bindir}/curl-config
}

# configure.ac in openEuler can't handle --without-libmetalink variable
EXTRA_OECONF:remove = " \
        --without-libmetalink \
"

# the version 7.86.0 packageconfig add libgsasl, openssl, zstd param and remove ssl param
PACKAGECONFIG[libgsasl] = "--with-libgsasl,--without-libgsasl,libgsasl"
PACKAGECONFIG[openssl] = "--with-openssl,--without-openssl,openssl"
PACKAGECONFIG[ssl] = ""
PACKAGECONFIG[zstd] = "--with-zstd,--without-zstd,zstd"

EXTRA_OECONF:append = " \
    ${@'--without-ssl' if (bb.utils.filter('PACKAGECONFIG', 'gnutls mbedtls nss openssl', d) == '') else ''} \
"

# It is not safe to pack crt files in rootfs by default, if you sure what you want, comment these lines:
EXTRA_OECONF:remove = " \
        --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
        --without-libmetalink \
"
RRECOMMENDS_lib${BPN}:remove = "ca-certificates"
