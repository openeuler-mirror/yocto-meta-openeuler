FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
# add gcompat DEPENDS to support musl
DEPENDS:append = " gcompat "

SRC_URI:append = " \
        file://isulad-musl.patch \
"
RDEPENDS:${PN}:remove = " \
        glibc-binary-localedata-en-us \
"
EXTRA_OECMAKE:append = " -DMUSL=1"
EXTRA_OECMAKE = "-DENABLE_GRPC=OFF -DENABLE_SYSTEMD_NOTIFY=OFF -DENABLE_SELINUX=OFF \
                -DENABLE_SHIM_V2=OFF -DENABLE_OPENSSL_VERIFY=OFF \
                -DGRPC_CONNECTOR=OFF -DDISABLE_OCI=ON \
                "
