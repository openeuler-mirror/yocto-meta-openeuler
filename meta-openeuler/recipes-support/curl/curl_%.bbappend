# main bbfile: yocto-poky/meta/recipes-support/curl/curl_7.75.0.bb

# version in openEuler
PV = "8.1.2"

# files, patches that come from openeuler
# do not apply backport-0101-curl-7.32.0-multilib.patch due to failure "libcurl.pc failed sanity test" when doing QA staging "pkg-config libcurl" in this patch
# note that 8.x version doesn't need any patches from poky.
SRC_URI = " \
        file://${BP}.tar.xz \
        file://backport-curl-7.84.0-test3026.patch \
        file://backport-curl-7.88.0-tests-warnings.patch \
        file://backport-CVE-2023-32001.patch \
"      

LIC_FILES_CHKSUM = "file://COPYING;md5=db8448a1e43eb2125f7740fc397db1f6"

EXTRA_OECONF:remove = " \
        --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
"

# in the ca-certificates package, there is no ca-certificates.crt file, so use ca-bundle.crt instead
EXTRA_OECONF:append = " \
    --with-ca-bundle=${sysconfdir}/ssl/certs/ca-bundle.crt \
"
