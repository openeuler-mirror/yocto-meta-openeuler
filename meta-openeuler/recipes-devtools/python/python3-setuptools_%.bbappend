PV = "59.4.0"
SRC_URI[md5sum] = "1cfee8bed453d447851114c0deca6ba1"
SRC_URI[sha256sum] = "b4c634615a0cf5b02cf83c7bedffc8da0ca439f00e79452699454da6fbd4153d"
require pypi-src-openeuler.inc

SRC_URI += " \
        file://backport-CVE-2022-40897.patch \
        file://bugfix-eliminate-random-order-in-metadata.patch \
"
