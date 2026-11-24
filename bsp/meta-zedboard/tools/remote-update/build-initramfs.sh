#!/bin/sh
# Pack the updater initramfs expected by zedboard-remote-update.py.
#
#   build-initramfs.sh --busybox busybox-arm-static --out updater.cpio.gz
#
# The busybox must be statically linked and built for armv7; see
# build-busybox.sh for a reproducible way to produce it from the
# src-openeuler busybox tree.
set -eu

busybox=
out=updater.cpio.gz
init="$(dirname "$0")/init"

usage() {
	sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
	--busybox) busybox=$2; shift 2 ;;
	--out) out=$2; shift 2 ;;
	--init) init=$2; shift 2 ;;
	-h|--help) usage ;;
	*) echo "unknown arg: $1" >&2; usage ;;
	esac
done

[ -n "$busybox" ] && [ -f "$busybox" ] || { echo "--busybox required" >&2; exit 1; }
[ -f "$init" ] || { echo "init script not found: $init" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

install -d "$tmp/bin"
install -m 0755 "$init" "$tmp/init"
install -m 0755 "$busybox" "$tmp/bin/busybox"
ln -s busybox "$tmp/bin/sh"

archive="$tmp.cpio"
(cd "$tmp" && find . -print0 | cpio --null -o -H newc) > "$archive"
[ -s "$archive" ] || { echo "error: cpio produced no archive" >&2; exit 1; }

gzip -9 -c "$archive" > "$out"
gzip -dc "$out" | cpio -t 2>/dev/null | grep -qxE '(\./)?init' || {
	echo "error: $out does not contain ./init" >&2
	exit 1
}
echo "wrote $out ($(wc -c < "$out") bytes)"