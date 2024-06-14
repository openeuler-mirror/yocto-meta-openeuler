PV = "4.7.1"
SRC_URI[md5sum] = "7761ed3842697b4e1de83e47ee2242d8"
SRC_URI[sha256sum] = "a1613838aa6b89af4ba10a0f3a972836128801ed008078f8c1244e65958f1b24"
require pypi-src-openeuler.inc

# apply openeuler's patches
SRC_URI_append = " \
        file://backport-CVE-2022-2309.patch \
        file://backport-Work-around-libxml2-bug-in-affected-versions.patch \
        file://Fix-test_elementtree-with-Expat-2.6.0.patch \
        "
