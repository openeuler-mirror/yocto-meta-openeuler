FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

PV = "1.15"

SRC_URI:remove = "file://disable-check.patch \
"

# upstream patch
SRC_URI:append = " file://0001-use-_Alignof-to-avoid-UB-in-ALIGNOF.patch \
"

SRC_URI[sha256sum] = "cc38744f817cf6814c847e2df37fcb8997357d72fa4bcbc228ae0fe47219a059"
