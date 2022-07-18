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
"

# files, patches that come from openeuler
# do not apply backport-0101-curl-7.32.0-multilib.patch due to failure "libcurl.pc failed sanity test" when doing QA staging "pkg-config libcurl" in this patch
SRC_URI += " \
        file://curl/${BP}.tar.xz;name=tarball \
"

SRC_URI[tarball.md5sum] = "74d3c4ca8aaa6c0619806d6e246e65fb"
SRC_URI[tarball.sha256sum] = "0606f74b1182ab732a17c11613cbbaf7084f2e6cca432642d0e3ad7c224c3689"

# configure.ac in openEuler can't handle --without-libmetalink variable
EXTRA_OECONF_remove = " \
        --without-libmetalink \
"
