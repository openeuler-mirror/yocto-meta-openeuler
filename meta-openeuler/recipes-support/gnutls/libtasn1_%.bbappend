SRC_URI:prepend = "file://${BP}.tar.gz \
        file://backport-CVE-2024-12133-part1.patch \
        file://backport-CVE-2024-12133-part2.patch \
"

ASSUME_PROVIDE_PKGS = "libtasn1"
