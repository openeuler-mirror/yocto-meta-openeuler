PV = "1.2.10"

SRC_URI:prepend = "file://${BP}.tar.bz2 "

# patches from src-openeuler spec (Patch1-6, Release 7)
SRC_URI:append = "file://alsa-lib-1.2.5.1-sw.patch \
                  file://backport-CVE-2026-25068.patch \
                  file://backport-CVE-2026-56109.patch \
                  file://backport-CVE-2026-90781.patch \
                  file://backport-CVE-2026-96674.patch \
                  file://backport-CVE-2026-96675.patch \
                  "

SRC_URI[sha256sum] = "dc9c643fdc4ccfd0572cc685858dd41e08afb583f30460b317e4188275f615b2"
