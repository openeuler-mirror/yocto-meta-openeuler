# Ship the MindSpore Lite test stack (mindspore-lite, demo-classification,
# opencv) when the distro feature is enabled. Gated so the reference image
# stays lean for machines that never use it: mindspore-lite and the demo are
# only validated on aarch64, and pulling mobilenetv2.ms from
# download-mindspore.osinfra.cn at build time should not become mandatory
# for every machine either.
# Enable with: DISTRO_FEATURES:append = " mindspore-lite" in local.conf
IMAGE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'mindspore-lite', \
    'mindspore-lite demo-classification opencv', '', d)}"
