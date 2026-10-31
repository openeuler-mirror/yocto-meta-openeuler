PV = "7.0"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
    file://0001-cifs.upcall-fix-UAF-in-get_cachename_from_process_en.patch \
    file://0002-cifs-utils-Make-automake-treat-sbin-as-exec-not-data.patch \
    file://0003-fix-compiler-warnings-in-mount.cifs.patch \
    file://0004-fix-CVE-2025-2312.patch \
    file://0005-fix-CVE-2026-12505.patch \
"

SRC_URI:remove = " \
                file://CVE-2022-27239.patch \
                file://CVE-2022-29869.patch \
"

SRC_URI[sha256sum] = "a7b6940e93250c1676a6fa66b6ead91b78cd43a5fee99cc462459c8b9cf1e6f4"

S = "${WORKDIR}/${BP}"

# keep the same as before, otherwise a large number of dependencies will be introduced
DEPENDS:remove = "libtalloc"
