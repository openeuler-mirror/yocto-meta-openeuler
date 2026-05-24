PV = "1.2.10"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
        file://alsa-lib-1.2.5.1-sw.patch \
        file://backport-CVE-2026-25068.patch \
"

# poky patches for 1.2.11 - not compatible with 1.2.10
SRC_URI:remove = " \
    file://0001-topology-correct-version-script-path.patch \
    file://CVE-2026-25068.patch \
"
