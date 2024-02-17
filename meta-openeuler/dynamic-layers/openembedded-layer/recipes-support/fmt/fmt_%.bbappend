# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/fmt/fmt_7.1.3.bb

# version in openEuler
PV = "8.0.1"

S = "${WORKDIR}/${BP}"


SRC_URI += " \
        file://${PV}.tar.gz \
        "

SRC_URI[md5sum] = "7d5af964c6633ef90cd6a47be3afe6a0"
SRC_URI[sha256sum] = "b06ca3130158c625848f3fb7418f235155a4d389b2abc3a6245fb01cb0eb1e01"

