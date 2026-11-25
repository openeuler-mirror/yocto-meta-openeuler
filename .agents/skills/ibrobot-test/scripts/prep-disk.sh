#!/bin/bash
# 在镜像输出目录（与 zImage/rootfs.cpio.gz 同级）执行：
#   qemu-img create -f raw ibrobot-disk.img 100G
#   sudo bash prep-disk.sh
# 脚本自定位同目录下的 *.rootfs.cpio.gz，losetup 挂镜像、mkfs.ext4、解 cpio、
# 设 root 密码、写 fstab；需 host sudo（losetup/mkfs/cpio）。
# 物理盘需显式确认：ALLOW_BLOCK_DEVICE=1。
set -euo pipefail

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMG="$OUT/ibrobot-disk.img"
CPIO="$(ls "$OUT"/openeuler-image-qemu-aarch64-*.rootfs.cpio.gz 2>/dev/null | head -1 || true)"
MNT="/mnt/ibrobot-disk"
ROOTPW="Aarch64@Qemu"

[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
[ -n "$CPIO" ] || { echo "no rootfs cpio in $OUT"; exit 1; }

# IMG 会被 mkfs.ext4 -F 格式化；改成物理盘前务必用 lsblk 核对设备
if [ -f "$IMG" ]; then
    :
elif [ -b "$IMG" ]; then
    [ "${ALLOW_BLOCK_DEVICE:-0}" = "1" ] || {
        echo "$IMG is a block device; re-run with ALLOW_BLOCK_DEVICE=1 after checking lsblk"
        exit 1
    }
else
    qemu-img create -f raw "$IMG" 100G
fi
DEV="$(losetup -fP --show "$IMG")"
mkfs.ext4 -F -m 1 "$DEV" >/dev/null 2>&1
mkdir -p "$MNT"
mount "$DEV" "$MNT"

cd "$MNT" && zcat "$CPIO" | cpio -idm >/dev/null 2>&1
cd - >/dev/null

# 设 root 密码 + 清掉强制改密（避免首登走 keyboard-interactive 改密流程）
chroot "$MNT" /bin/bash -c "echo 'root:$ROOTPW' | chpasswd && chage -m 0 -M 99999 -E -1 -W -1 -I -1 root && chage -d \"\$(date +%Y-%m-%d)\" root"
grep -q '^[^#].*[[:space:]]/[[:space:]]' "$MNT/etc/fstab" 2>/dev/null || \
    echo '/dev/vda / ext4 defaults,rw 0 1' >> "$MNT/etc/fstab"

cd /
umount "$MNT"
losetup -d "$DEV"
echo "DONE: $IMG"