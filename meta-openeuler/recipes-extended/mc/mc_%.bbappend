# bbfile: yocto-poky/meta/recipes-extended/mc/mc_4.8.27.bb

PV = "4.8.29"

SRC_URI = "file://${PV}.tar.gz \
        file://mc-spec.syntax.patch \
        file://mc-python3.patch \
        file://mc-default_setup.patch \
        file://mc-tmpdir.patch \
        "

SRC_URI[sha256sum] = "09c8b9689d065e5a59d380338ed0bc0d529b3dcab860a40655333928a2b2e0ba"

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
