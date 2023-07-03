# the main bb file: yocto-poky/meta/recipes-support/libseccomp/libseccomp_2.5.3.bb

PV = "2.5.4"

SRC_URI:remove = " \
    git://github.com/seccomp/libseccomp.git;branch=release-2.5;protocol=https \
"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://backport-arch-disambiguate-in-arch-syscall-validate.patch \
"

S = "${WORKDIR}/${BP}"
