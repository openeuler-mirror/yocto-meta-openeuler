FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

PV = "1.16"

SRC_URI:remove = "file://disable-check.patch \
"

# upstream patch
SRC_URI:append = " file://${BP}.tar.xz \
file://0001-use-_Alignof-to-avoid-UB-in-ALIGNOF.patch \
"

SRC_URI[sha256sum] = "4348566aa0fbf196db5e0a576321c65966189210cb51328ea2bb2be39c711d71"
