# bb file: yocto-poky/meta/recipes-support/libyaml/libyaml_0.2.5.bb

OPENEULER_SRC_URI_REMOVE = "https"

SRC_URI += "file://yaml-${PV}.tar.gz \
        file://fix-heap-buffer-overflow-in-yaml_emitter_emit_flow_m.patch  \
        file://fix-heap-buffer-overflow-error-in-yaml-emitter-emit.patch \
        file://backport-Improve-CMake-build-system.patch \
"
