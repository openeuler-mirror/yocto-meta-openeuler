OPENEULER_SRC_URI_REMOVE = "https http"

PV = "3.22.0"

SRC_URI:remove = " \
"

# apply openeuler source package and patches
SRC_URI:prepend = " \
           file://cmake-${PV}.tar.gz \
           file://cmake-findruby.patch \
           file://cmake-fedora-flag_release.patch \
           file://cmake-mingw-dl.patch \
"

SRC_URI[sha256sum] = "998c7ba34778d2dfdb3df8a695469e24b11e2bfa21fbe41b361a3f45e1c9345e"
