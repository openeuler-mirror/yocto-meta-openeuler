FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
# add MARCO to support musl
EXTRA_OECMAKE:append = " -DMUSL=1"
