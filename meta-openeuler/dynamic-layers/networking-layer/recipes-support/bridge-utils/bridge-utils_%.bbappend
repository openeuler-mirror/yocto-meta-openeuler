# main bbfile: meta-networking/recipes-support/bridge-utils/bridge-utils_1.7.1.bb;branch=master

# version in openEuler
PV = "1.7.1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = "\
    git://git.kernel.org/pub/scm/network/bridge/bridge-utils.git;branch=main \
"

# files, patches that come from openeuler
SRC_URI:prepend = "\
    file://${BP}.tar.gz \
    file://bugfix-avoid-showmacs-memory-leak.patch \
    file://bugfix-bridge-not-check-parameters.patch \
"

SRC_URI[md5sum] = "73fd3b90947d6382118fdd8c63d42e0c"
SRC_URI[sha256sum] = "74a2ef0dcadc525825942e37d0bd28c5cfdbd8e4cd83c028f90f3a3731983216"

S = "${WORKDIR}/${BP}"

