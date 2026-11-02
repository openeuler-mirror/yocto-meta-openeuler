# openeuler PV
PV = "2.55.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# 2.41.0 sha256sum
SRC_URI[tarball.sha256sum] = "457fdb04dc8728e007d4688695e6912e6f680727920f2a40bf11eacc17505357"

# openeuler SRC_URI
SRC_URI:prepend = "file://${BP}.tar.xz \
                  file://backport-CVE-2026-32631-mingw-skip-symlink-type-auto-detection-for-network-s.patch \
                  file://backport-CVE-2026-62960-bundle-uri-refuse-advertised-URIs-by-protocol.patch \
                  "

S = "${WORKDIR}/${BP}"
