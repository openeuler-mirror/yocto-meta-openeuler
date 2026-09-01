
PV = "3.7.1"

# openeuler src
SRC_URI:prepend = "file://${BP}.tar.gz \
            file://backport-CVE-2024-20697-CVE-2024-26256.patch \
            file://backport-CVE-2024-20696.patch \
           "

FILESEXTRAPATHS:append := "${THISDIR}/${BPN}/:"

# keep same as upstream
SRC_URI += "file://configurehack.patch"

PACKAGECONFIG:remove = "lzo"
