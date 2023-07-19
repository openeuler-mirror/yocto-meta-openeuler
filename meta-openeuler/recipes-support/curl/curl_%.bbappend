# main bbfile: yocto-poky/meta/recipes-support/curl/curl_7.75.0.bb

# version in openEuler
PV = "7.79.1"

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
        file://${BP}.tar.xz;name=tarball \
        file://backport-CVE-2022-22576.patch \
        file://backport-CVE-2022-27775.patch \
        file://backport-CVE-2022-27776.patch \
        file://backport-pre-CVE-2022-27774.patch \
        file://backport-001-CVE-2022-27774.patch \
        file://backport-002-CVE-2022-27774.patch \
        file://backport-CVE-2022-27781.patch \
        file://backport-pre-CVE-2022-27782.patch \
        file://backport-CVE-2022-27782.patch \
        file://backport-CVE-2022-32205.patch \
        file://backport-CVE-2022-32206.patch \
        file://backport-CVE-2022-32207.patch \
        file://backport-CVE-2022-32208.patch \
        file://backport-fix-configure-disable-http-auth-build-error.patch \
        file://backport-CVE-2022-35252-cookie-reject-cookies-with-control-bytes.patch \
        file://backport-CVE-2022-32221.patch \
        file://backport-CVE-2022-42916.patch \
        file://backport-0001-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0002-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0003-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0004-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0005-CVE-2023-23914-CVE-2023-23915.patch \
        file://backport-0001-CVE-2023-23916.patch \
        file://backport-0002-CVE-2023-23916.patch \
        file://backport-multi-shut-down-CONNECT-in-Curl_detach_connnection.patch \
        file://backport-curl_easy_cleanup.3-remove-from-multi-handle-first.patch \
        file://backport-http_proxy-make-Curl_connect_done-work-for-proxy-dis.patch \
        file://backport-Curl_connect_done-handle-being-called-twice.patch \
        file://backport-tftp-mark-protocol-as-not-possible-to-do-over-CONNEC.patch \
        file://backport-test1939-require-proxy-support-to-run.patch \
        file://backport-lib1939-make-it-endure-torture-tests.patch \
        file://backport-CVE-2022-42915.patch \
"

SRC_URI[tarball.md5sum] = "74d3c4ca8aaa6c0619806d6e246e65fb"
SRC_URI[tarball.sha256sum] = "0606f74b1182ab732a17c11613cbbaf7084f2e6cca432642d0e3ad7c224c3689"

# configure.ac in openEuler can't handle --without-libmetalink variable
EXTRA_OECONF_remove = " \
        --without-libmetalink \
"

# It is not safe to pack crt files in rootfs by default, if you sure what you want, comment these lines:
EXTRA_OECONF_remove += " \
        --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
"
RRECOMMENDS_lib${BPN}_remove += "ca-certificates"

