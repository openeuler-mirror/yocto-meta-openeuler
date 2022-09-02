#main bbfile: yocto-poky/meta/recipes-extended/libnsl/libnsl2_git.bb

#version in openEuler
PV = "2.0.0"

S = "${WORKDIR}/libnsl-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            git://github.com/thkukuk/libnsl \
            "
# files, patches that come from openeuler
SRC_URI += " \
        file://libnsl2/libnsl-2.0.0.tar.gz \
        "

SRC_URI[tarball.md5sum] = "e1ee6772c2ee5ddc25ea465a33af3004"
SRC_URI[tarball.sha256sum] = "eb37be57c1cf650b3a8a4fc7cd66c8b3dfc06215b41956a16325a9388171bc40"
