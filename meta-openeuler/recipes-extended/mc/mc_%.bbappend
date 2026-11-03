# bbfile: yocto-poky/meta/recipes-extended/mc/mc_4.8.27.bb

PV = "4.8.33"

SRC_URI = "file://${BP}.tar.xz \
        file://mc-spec.syntax.patch \
        file://mc-default_setup.patch \
        file://mc-tmpdir.patch \
        "

SRC_URI[sha256sum] = "cae149d42f844e5185d8c81d7db3913a8fa214c65f852200a9d896b468af164c"

PACKAGECONFIG[smb] = ",,,"

EXTRA_OECONF += "--disable-nls"

do_configure:prepend() {
    mkdir -p ${S}/config
    touch ${S}/config/config.rpath
    touch ${S}/ABOUT-NLS
}

do_configure:append() {
    printf 'all:\ninstall:\nclean:\ndistdir:\n' > ${B}/po/Makefile
}

ASSUME_PROVIDE_PKGS = "mc"
