PV = "4.9.1"
SRC_URI[md5sum] = "e27240a7319d80d0c1e5390ca31eb1d8"
SRC_URI[sha256sum] = "fe749b052bb7233fe5d072fcb549221a8cb1a16725c47c37e42b0b9cb3ff2c3f"
require pypi-src-openeuler.inc

SRC_URI:remove = "file://CVE-2022-2309.patch \
"

# apply openeuler's patches
SRC_URI:append = " \
        file://backport-Work-around-libxml2-bug-in-affected-versions.patch \
        "
