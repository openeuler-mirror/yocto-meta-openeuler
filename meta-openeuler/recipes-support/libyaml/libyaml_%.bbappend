
SRC_URI += " \
        file://yaml-${PV}.tar.gz \
        file://fix-heap-buffer-overflow-in-yaml_emitter_emit_flow_m.patch  \
        file://fix-heap-buffer-overflow-error-in-yaml-emitter-emit.patch \
        file://backport-Improve-CMake-build-system.patch \
"
