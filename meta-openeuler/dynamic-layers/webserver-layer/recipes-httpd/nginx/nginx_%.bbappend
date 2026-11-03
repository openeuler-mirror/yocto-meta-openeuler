# main bb: yocto-meta-openembedded/meta-webserver/recipes-httpd/nginx/nginx.inc

PV = "1.24.0"

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

# CVE and bugfix backports from src-openeuler nginx.spec (Patch3 .. Patch6003)
SRC_URI:append = " \
    file://backport-CVE-2023-44487.patch \
    file://backport-CVE-2024-7347.patch \
    file://backport-CVE-2025-23419.patch \
    file://backport-Fixed-segfault-if-regex-studies-list-allocation-fails.patch \
    file://backport-Core-fixed-memory-leak-on-configuration-reload-with-PCRE2.patch \
    file://backport-CVE-2025-53859.patch \
    file://backport-CVE-2025-53859-after-Mail-reset-stale-auth-credentials-with-smtp_auth-none.patch \
    file://backport-CVE-2025-53859-after-Mail-logging-upstream-to-the-error-log-with-smtp_auth-none.patch \
    file://backport-CVE-2026-1642.patch \
    file://backport-CVE-2026-27654.patch \
    file://backport-CVE-2026-27784.patch \
    file://backport-CVE-2026-32647.patch \
    file://backport-CVE-2026-27651.patch \
    file://backport-CVE-2026-28753.patch \
    file://backport-CVE-2026-42945.patch \
    file://backport-0001-CVE-2026-42946.patch \
    file://backport-0002-CVE-2026-42946.patch \
    file://backport-CVE-2026-40701.patch \
    file://backport-CVE-2026-42934.patch \
    file://CVE-2026-9256.patch \
    file://backport-CVE-2026-49975.patch \
    file://backport-0001-CVE-2026-42055.patch \
    file://backport-0002-CVE-2026-42055.patch \
    file://backport-CVE-2026-48142.patch \
    file://backport-CVE-2026-56434.patch \
    file://backport-CVE-2026-60005.patch \
    file://backport-pre-CVE-2026-42533.patch \
    file://backport-0001-CVE-2026-42533.patch \
    file://backport-0002-CVE-2026-42533.patch \
    file://backport-0003-CVE-2026-42533.patch \
    file://backport-CVE-2026-15176.patch \
    file://backport-CVE-2026-93479.patch \
    file://backport-CVE-2026-97205.patch \
    file://backport-CVE-2026-97629.patch \
"
