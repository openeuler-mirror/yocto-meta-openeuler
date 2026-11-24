#!/bin/sh
# Cross-build a statically linked busybox for the updater initramfs.
#
#   build-busybox.sh --tarball busybox-1.36.1.tar.bz2 \
#       --config busybox-static.config \
#       --cross arm-openeuler-linux-gnueabi- \
#       --out busybox-arm-static
#
# Both inputs come from the src-openeuler busybox tree; the static config
# must contain CONFIG_STATIC=y so the binary runs without libc in initramfs.
set -eu

tarball=
config=
cross=
out=busybox-arm-static
jobs=$(nproc)

usage() {
	sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
	--tarball) tarball=$2; shift 2 ;;
	--config) config=$2; shift 2 ;;
	--cross) cross=$2; shift 2 ;;
	--out) out=$2; shift 2 ;;
	--jobs) jobs=$2; shift 2 ;;
	-h|--help) usage ;;
	*) echo "unknown arg: $1" >&2; usage ;;
	esac
done

[ -f "$tarball" ] || { echo "--tarball required" >&2; exit 1; }
[ -f "$config" ] || { echo "--config required" >&2; exit 1; }
[ -n "$cross" ] || { echo "--cross required (e.g. arm-openeuler-linux-gnueabi-)" >&2; exit 1; }
command -v "${cross}gcc" >/dev/null || { echo "${cross}gcc not in PATH" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

tar xf "$tarball" -C "$tmp"
src=$(find "$tmp" -maxdepth 1 -type d -name 'busybox-*' | head -1)
cp "$config" "$src/.config"

# The external arm toolchain ships a glibc without Sun RPC headers, so the
# inetd RPC applet cannot be built; it is not needed in the updater.
sed -i 's/^CONFIG_FEATURE_INETD_RPC=y/# CONFIG_FEATURE_INETD_RPC is not set/' \
	"$src/.config"

yes "" | make -C "$src" CROSS_COMPILE="$cross" oldconfig >/dev/null
grep -q '^CONFIG_STATIC=y' "$src/.config" || {
	echo "config does not set CONFIG_STATIC=y" >&2
	exit 1
}
make -C "$src" CROSS_COMPILE="$cross" -j"$jobs" >/dev/null

file "$src/busybox" | grep -q 'statically linked' || {
	echo "warning: busybox is not statically linked" >&2
}
install -m 0755 "$src/busybox" "$out"
echo "wrote $out ($(wc -c < "$out") bytes)"