FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:remove = "file://external.sh"
SRC_URI:append = "\
    file://clang-external.sh \
"

do_install () {
    install -d "${D}/environment-setup.d"
    install -m 0644 -o root -g root "${WORKDIR}/clang-external.sh" "${D}/environment-setup.d/"
}
