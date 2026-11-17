#!/bin/bash
# Derive a stable per-board MAC address from the eMMC CID.
#
# Shared images get a different deterministic MAC on every board, and the
# value survives rootfs/kernel reflashes because the eMMC CID is hardware.
set -u

IFACE=${1:-eth0}

cid=$(cat /sys/class/mmc_host/mmc0/mmc0:*/cid 2>/dev/null | head -n1)
if [ -z "$cid" ]; then
    cid=$(cat /sys/block/mmcblk0/device/serial 2>/dev/null)
fi
if [ -z "$cid" ]; then
    echo "hieulerpi1-set-mac: no eMMC CID, leaving MAC unchanged" >&2
    exit 0
fi

hash=$(printf 'hieulerpi1-mac-v1:%s:%s' "$cid" "$IFACE" | sha256sum | cut -c1-12)
b0=$(( 0x${hash:0:2} & 0xFC | 0x02 ))
mac=$(printf '%02x:%s:%s:%s:%s:%s' "$b0" \
    "${hash:2:2}" "${hash:4:2}" "${hash:6:2}" "${hash:8:2}" "${hash:10:2}")

i=0
while [ "$i" -lt 10 ] && [ ! -e "/sys/class/net/$IFACE" ]; do
    sleep 1
    i=$((i + 1))
done
if [ ! -e "/sys/class/net/$IFACE" ]; then
    echo "hieulerpi1-set-mac: interface $IFACE not found" >&2
    exit 0
fi

if ! ip link set dev "$IFACE" address "$mac"; then
    echo "hieulerpi1-set-mac: failed to set MAC on $IFACE" >&2
    exit 1
fi

echo "$mac" > /run/hieulerpi1-mac
echo "hieulerpi1-set-mac: $IFACE -> $mac (cid $cid)"