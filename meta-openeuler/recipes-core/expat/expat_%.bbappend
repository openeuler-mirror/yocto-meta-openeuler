# the main bb file: yocto-poky/meta/recipes-core/expat/expat_2.5.0.bb


LIC_FILES_CHKSUM = "file://COPYING;md5=f4fedd6116da0e171f7cb4d2923d7ac2"

PV = "2.9.0"

SRC_URI[sha256sum] = "1e6371862cc31999b368c3b89b49994f0677e1bab5f1b2b85ae3741f5d803051"

# tar from openeuler (upstream switched to .tar.xz in 2.9.0)
SRC_URI = " \
    file://${BP}.tar.xz \
"

ASSUME_PROVIDE_PKGS = "expat"
