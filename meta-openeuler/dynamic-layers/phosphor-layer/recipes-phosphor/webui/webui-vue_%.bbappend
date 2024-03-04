# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

SRC_URI += " \
    file://${BPN} \
"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/${BPN}"

do_compile:prepend () {
    # the original registry is https://registry.npmjs.org/, 
    # too slow in China!!!!!!!!
    # use the Chinese mirror instead
    npm config set registry https://registry.npmmirror.com/
}