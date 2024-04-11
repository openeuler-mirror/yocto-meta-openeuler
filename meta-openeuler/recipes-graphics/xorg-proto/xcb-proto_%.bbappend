FILESEXTRAPATHS:append := "${THISDIR}/files/:"

PV = "1.16.0"

SRC_URI:prepend = "file://${BP}.tar.xz \
        file://0001-xcb-proto.pc.in-reinstate-libdir.patch \
        file://0001-Fix-install-conflict-when-enable-multilib.patch \
"

SRC_URI[sha256sum] = "0e434af76af722ef9b2dc21066da1cd11e5dd85fc1996d66228d090f9ae9b217"
