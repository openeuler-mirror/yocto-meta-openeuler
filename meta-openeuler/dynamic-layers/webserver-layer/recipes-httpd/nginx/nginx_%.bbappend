# main bb: yocto-meta-openembedded/meta-webserver/recipes-httpd/nginx/nginx.inc

PV = "1.23.3"

LIC_FILES_CHKSUM = "file://LICENSE;md5=175abb631c799f54573dc481454c8632"

SRC_URI:remove = " \
    file://0001-Allow-the-overriding-of-the-endianness-via-the-confi.patch \
    file://CVE-2021-3618.patch \
    file://CVE-2022-41741-CVE-2022-41742.patch \
"

SRC_URI:prepend = " \
    file://nginx-${PV}.tar.gz \
    file://nginx-auto-cc-gcc.patch \
    file://nginx-1.12.1-logs-perm.patch \
"
