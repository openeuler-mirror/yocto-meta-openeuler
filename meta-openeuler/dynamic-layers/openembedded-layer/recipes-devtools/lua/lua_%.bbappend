# the main bb file: yocto-poky/meta/recipes-devtools/lua/lua_5.4.4.bb

# openeuler version
PV = "5.4.6"

# remove patches out of date
SRC_URI:remove = " \
           file://CVE-2022-28805.patch \
           file://CVE-2022-33099.patch \
           "

# openeuler has patches for lua-${PV}-tests
SRC_URI:prepend = " \
           file://${BP}.tar.gz;name=tarballsrc \
"

LIC_FILES_CHKSUM = "file://doc/readme.html;beginline=303;endline=324;md5=e05449eb28c092473f854670c6e8375a"

do_install_ptest:append:libc-musl () {
        # locale tests does not work on musl, due to limited locale implementation
        # https://wiki.musl-libc.org/open-issues.html#Locale-limitations
        sed -i -e 's|os.setlocale("pt_BR") or os.setlocale("ptb")|false|g' ${D}${PTEST_PATH}/test/literals.lua
}
