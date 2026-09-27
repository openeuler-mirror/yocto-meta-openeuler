# bbfile: yocto-meta-openembedded/meta-oe/recipes-kernel/libbpf/libbpf_0.7.0.bb
#
# Bump libbpf for native BTF tooling only (class-native): pahole 1.28
# fails to emit the ENUM64 BTF types used by the sched_ext code in the
# openEuler 6.6 kernel when linked against the meta-oe libbpf 0.7.0
# ("Error emitting BTF type (libbpf error -95)"); libbpf gained enum64
# support in v1.0. Take the openEuler-adapted 1.2.2 tarball from the
# src-openeuler/libbpf packaging (fetched through the manifest, like
# the pahole tarball) so pahole can generate the vmlinux BTF with
# CONFIG_DEBUG_INFO_BTF enabled. Target builds keep the meta-oe 0.7.0
# baseline.

PV:class-native = "1.2.2"
SRC_URI:class-native = "file://v1.2.2.tar.gz"
S:class-native = "${WORKDIR}/libbpf-1.2.2/src"
