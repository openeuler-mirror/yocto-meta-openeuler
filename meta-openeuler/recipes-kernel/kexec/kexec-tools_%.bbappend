# main bbfile: yocto-poky/meta/recipes-kernel/kexec/kexec-tools_2.0.21.bb

# kexec-tools version in openEuler
PV = "2.0.26"

# Use the source packages from openEuler and remove conflicting patches
SRC_URI:remove = " \
                  file://0001-arm64-kexec-disabled-check-if-kaslr-seed-dtb-propert.patch \
                  "
SRC_URI:prepend = "file://${BP}.tar.xz "

SRC_URI += "file://kexec-Add-quick-kexec-support.patch \
            file://kexec-Quick-kexec-implementation-for-arm64.patch \
            "

SRC_URI[md5sum] = "ce3c79e0f639035ef7ddfc39b286a61a"
SRC_URI[sha256sum] = "7fe36a064101cd5c515e41b2be393dce3ca88adce59d6ee668e0af7c0c4570cd"
