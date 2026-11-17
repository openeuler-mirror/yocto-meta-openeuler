#!/bin/bash
# Host-side one-shot upgrade tool for hieulerpi1.
#
# Uploads kernel-pi and rootfs.ext4 directly to the board's mounted SD card,
# installs the one-shot U-Boot env file, arms update=yes and reboots. U-Boot
# then flashes eMMC and boots the new system.
#
# Large-file reads through the board's Linux filesystem are not reliable on
# this platform, so this tool deliberately skips remote md5 verification and
# uses the actual U-Boot flash as the final check. Remote file sizes are
# verified, and the host-side md5 values are printed for reference.
set -eu

PROG=$(basename "$0")
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

REPO_ROOT=""
probe=$SCRIPT_DIR
while [ "$probe" != "/" ]; do
    if [ -d "$probe/.oebuild" ] && [ -d "$probe/meta-openeuler" ]; then
        REPO_ROOT=$probe
        break
    fi
    probe=$(dirname "$probe")
done

if [ -n "$REPO_ROOT" ]; then
    DEFAULT_KEY="$REPO_ROOT/meta-openeuler/recipes-core/images/files/test-ssh/id_ed25519"
    ENV_TEMPLATE="$REPO_ROOT/bsp/meta-hisilicon/tools/hieulerpi1-env-append.txt"
else
    DEFAULT_KEY=""
    ENV_TEMPLATE=""
fi
KERNEL_PART_SIZE=16777216

IP=""
SSH_USER="root"
PASSWORD=""
KEY=""
USE_DEFAULT_KEY=yes
SD_DEV="/dev/mmcblk1p1"
SD_MOUNT="/mnt/sd"
TRANSFER="auto"
REBOOT=yes
WAIT_SEC=0
ASSUME_YES=no
KERNEL=""
ROOTFS=""

usage() {
    cat <<EOF
Usage: $PROG --ip <addr> --kernel <kernel-pi> --rootfs <rootfs.ext4> [options]

Upload the images directly to a running hieulerpi1 board's SD card, arm the
one-shot U-Boot upgrade, and reboot. U-Boot flashes eMMC on the next boot.

Required:
      --ip <addr>             board IP address
      --kernel <path>         kernel-pi image (must fit the 16MiB partition)
      --rootfs <path>         rootfs ext4 image

Authentication (tried in this order):
  -k, --key <path>            SSH private key
      --no-key                do not use the built-in test key
  -p, --password <pass>       SSH password, used if key auth fails

Options:
  -u, --user <user>           SSH user (default: root)
      --sd-dev <device>       SD partition on the board (default: /dev/mmcblk1p1)
      --sd-mount <dir>        mount point on the board (default: /mnt/sd)
      --transfer auto|scp|rsync
                              transfer tool (default: auto)
      --no-reboot             stage on SD only, do not reboot
      --wait <seconds>        after reboot, wait for SSH to come back
  -y, --yes                   do not ask for confirmation
  -h, --help                  show this help

Examples:
  $PROG --ip 192.168.7.3 \\
      --kernel build/hieulerpi1/output/20261116161223/kernel-pi \\
      --rootfs build/hieulerpi1/output/20261116161223/openeuler-image-hieulerpi1-20261116161223.rootfs.ext4

  $PROG --ip 192.168.7.3 --password openEuler@2021 \\
      --kernel /tmp/kernel-pi --rootfs /tmp/rootfs.ext4 --no-reboot

Notes:
  The SD card must be inserted and contain a mountable filesystem with a
  /boot directory (created automatically). The private key shipped in
  meta-openeuler/recipes-core/images/files/test-ssh/ is a shared test key;
  do not use it for production images.

  This tool skips remote md5 verification of the large rootfs image because
  Linux filesystem reads of large files are unreliable on this board.
  Remote sizes are checked and the actual U-Boot flash is the final test.
  --wait assumes the board keeps the same IP after the upgrade; the new image
  normally disables password SSH, so keep the built-in test key available.
EOF
}

log() { echo "[$PROG] $*"; }
die() { echo "[$PROG] ERROR: $*" >&2; exit 1; }
shq() { printf '%q' "$1"; }

need_arg() { [ $# -ge 2 ] || die "option $1 requires a value"; }

while [ $# -gt 0 ]; do
    case "$1" in
        --ip) need_arg "$@"; IP=$2; shift 2 ;;
        --kernel) need_arg "$@"; KERNEL=$2; shift 2 ;;
        --rootfs) need_arg "$@"; ROOTFS=$2; shift 2 ;;
        -k|--key) need_arg "$@"; KEY=$2; shift 2 ;;
        --no-key) USE_DEFAULT_KEY=no; shift ;;
        -p|--password) need_arg "$@"; PASSWORD=$2; shift 2 ;;
        -u|--user) need_arg "$@"; SSH_USER=$2; shift 2 ;;
        --sd-dev) need_arg "$@"; SD_DEV=$2; shift 2 ;;
        --sd-mount) need_arg "$@"; SD_MOUNT=$2; shift 2 ;;
        --transfer) need_arg "$@"; TRANSFER=$2; shift 2 ;;
        --no-reboot) REBOOT=no; shift ;;
        --wait) need_arg "$@"; WAIT_SEC=$2; shift 2 ;;
        -y|--yes) ASSUME_YES=yes; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) die "unknown option: $1 (use --help)" ;;
        *)
            if [ -z "$KERNEL" ]; then KERNEL=$1
            elif [ -z "$ROOTFS" ]; then ROOTFS=$1
            else die "unexpected argument: $1"
            fi
            shift
            ;;
    esac
done

[ -n "$IP" ] || { usage; die "--ip is required"; }
[ -n "$KERNEL" ] || { usage; die "--kernel is required"; }
[ -n "$ROOTFS" ] || { usage; die "--rootfs is required"; }
[ -f "$KERNEL" ] || die "kernel image not found: $KERNEL"
[ -f "$ROOTFS" ] || die "rootfs image not found: $ROOTFS"
[ -f "$ENV_TEMPLATE" ] || die "env template not found: $ENV_TEMPLATE"
case "$TRANSFER" in auto|scp|rsync) ;; *) die "invalid --transfer: $TRANSFER" ;; esac

KERNEL_SIZE=$(wc -c < "$KERNEL")
ROOTFS_SIZE=$(wc -c < "$ROOTFS")
[ "$KERNEL_SIZE" -le "$KERNEL_PART_SIZE" ] ||
    die "kernel image is larger than 16MiB ($KERNEL_SIZE bytes)"
[ "$ROOTFS_SIZE" -gt 0 ] || die "rootfs image is empty"

case "$WAIT_SEC" in
    ''|*[!0-9]*) die "--wait expects a number of seconds" ;;
esac

KEY_TMP=""
cleanup() { if [ -n "$KEY_TMP" ]; then rm -f "$KEY_TMP"; fi; }
trap cleanup EXIT INT TERM

if [ -z "$KEY" ] && [ "$USE_DEFAULT_KEY" = yes ] && [ -f "$DEFAULT_KEY" ]; then
    KEY=$DEFAULT_KEY
fi
if [ -n "$KEY" ]; then
    [ -f "$KEY" ] || die "SSH key not found: $KEY"
    KEY_TMP=$(mktemp /tmp/hieulerpi1-key.XXXXXX)
    cp "$KEY" "$KEY_TMP"
    chmod 600 "$KEY_TMP"
fi

SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
          -o ConnectTimeout=10 -o ServerAliveInterval=15)
AUTH=""

if [ -n "$KEY_TMP" ]; then
    if ssh "${SSH_OPTS[@]}" -i "$KEY_TMP" -o IdentitiesOnly=yes -o BatchMode=yes \
        "$SSH_USER@$IP" 'exit 0' >/dev/null 2>&1; then
        AUTH=key
    fi
fi

if [ -z "$AUTH" ] && [ -n "$PASSWORD" ]; then
    command -v sshpass >/dev/null || die "sshpass is required for --password"
    if SSHPASS="$PASSWORD" sshpass -e ssh "${SSH_OPTS[@]}" \
        -o PreferredAuthentications=password -o PubkeyAuthentication=no \
        "$SSH_USER@$IP" 'exit 0' >/dev/null 2>&1; then
        AUTH=password
    fi
fi

case "$AUTH" in
    key) log "authenticated to $SSH_USER@$IP with key" ;;
    password) log "authenticated to $SSH_USER@$IP with password" ;;
    *) die "cannot authenticate to $SSH_USER@$IP (tried key/password)" ;;
esac

ssh_run() {
    if [ "$AUTH" = key ]; then
        ssh "${SSH_OPTS[@]}" -i "$KEY_TMP" -o IdentitiesOnly=yes -o BatchMode=yes \
            "$SSH_USER@$IP" "$@"
    else
        SSHPASS="$PASSWORD" sshpass -e ssh "${SSH_OPTS[@]}" \
            -o PreferredAuthentications=password -o PubkeyAuthentication=no \
            "$SSH_USER@$IP" "$@"
    fi
}

scp_to() {
    local src=$1 dst=$2
    if [ "$AUTH" = key ]; then
        scp "${SSH_OPTS[@]}" -i "$KEY_TMP" -o IdentitiesOnly=yes -o BatchMode=yes \
            "$src" "$SSH_USER@$IP:$dst"
    else
        SSHPASS="$PASSWORD" sshpass -e scp "${SSH_OPTS[@]}" \
            -o PreferredAuthentications=password -o PubkeyAuthentication=no \
            "$src" "$SSH_USER@$IP:$dst"
    fi
}

ssh_run_any() {
    if [ -n "$KEY_TMP" ] && ssh "${SSH_OPTS[@]}" -i "$KEY_TMP" \
        -o IdentitiesOnly=yes -o BatchMode=yes "$SSH_USER@$IP" "$@" 2>/dev/null; then
        return 0
    fi
    if [ -n "$PASSWORD" ] && command -v sshpass >/dev/null 2>&1 &&
        SSHPASS="$PASSWORD" sshpass -e ssh "${SSH_OPTS[@]}" \
        -o PreferredAuthentications=password -o PubkeyAuthentication=no \
        "$SSH_USER@$IP" "$@" 2>/dev/null; then
        return 0
    fi
    return 1
}

SD_DEV_Q=$(shq "$SD_DEV")
SD_MOUNT_Q=$(shq "$SD_MOUNT")

log "mounting the SD card on the board"
ssh_run "set -e
test -b $SD_DEV_Q || { echo \"SD device not found: $SD_DEV\"; exit 2; }
command -v fw_setenv >/dev/null || { echo 'fw_setenv missing'; exit 2; }
command -v wc >/dev/null || { echo 'wc missing'; exit 2; }
grep -q \" $SD_MOUNT \" /proc/mounts || { mkdir -p $SD_MOUNT_Q; mount $SD_DEV_Q $SD_MOUNT_Q; }
mkdir -p $SD_MOUNT_Q/boot
df -Pk $SD_MOUNT_Q | awk 'NR == 2 { print \"available_kb=\" \$4 }'
model=\$(cat /proc/device-tree/model 2>/dev/null || true)
case \"\$model\" in *ieuler*|*ss928*) ;; *) echo \"warning: board model is '\$model'\" >&2 ;; esac
" || die "board prerequisite check failed"

AVAIL_KB=$(ssh_run "df -Pk $SD_MOUNT_Q | awk 'NR == 2 { print \$4 }'")
NEED_KB=$(( (KERNEL_SIZE + ROOTFS_SIZE) / 1024 + 262144 ))
[ "$AVAIL_KB" -ge "$NEED_KB" ] ||
    die "not enough space on $SD_DEV (need ${NEED_KB}KiB, have ${AVAIL_KB}KiB)"

HOST_KERNEL_MD5=$(md5sum "$KERNEL" | awk '{print $1}')
HOST_ROOTFS_MD5=$(md5sum "$ROOTFS" | awk '{print $1}')

if [ "$ASSUME_YES" != yes ]; then
    cat <<EOF

Board:    $SSH_USER@$IP
SD:       $SD_DEV mounted at $SD_MOUNT
Kernel:   $KERNEL ($KERNEL_SIZE bytes, md5 $HOST_KERNEL_MD5)
Rootfs:   $ROOTFS ($ROOTFS_SIZE bytes, md5 $HOST_ROOTFS_MD5)
Action:   stage on SD and $([ "$REBOOT" = yes ] && echo "reboot into the new system" || echo "stop (--no-reboot)")

Remote md5 verification is skipped: large filesystem reads are unreliable on
this board. Remote sizes are checked; the U-Boot flash is the final test.

EOF
    printf 'Continue? [y/N] '
    read -r answer || answer=""
    case "$answer" in y|Y|yes|YES) ;; *) die "aborted" ;; esac
fi

use_rsync=no
if [ "$TRANSFER" != scp ] && command -v rsync >/dev/null 2>&1 &&
    ssh_run 'command -v rsync >/dev/null 2>&1'; then
    use_rsync=yes
fi
if [ "$TRANSFER" = rsync ] && [ "$use_rsync" != yes ]; then
    die "rsync requested but not available on host or board"
fi

REMOTE_KERNEL="$SD_MOUNT/boot/kernel.new"
REMOTE_ROOTFS="$SD_MOUNT/boot/rootfs.ext4.new"
REMOTE_ENV="$SD_MOUNT/boot/env_append.txt"
REMOTE_KERNEL_Q=$(shq "$REMOTE_KERNEL")
REMOTE_ROOTFS_Q=$(shq "$REMOTE_ROOTFS")
REMOTE_ENV_Q=$(shq "$REMOTE_ENV")

log "uploading images to $SD_MOUNT ($([ "$use_rsync" = yes ] && echo rsync || echo scp))"
if [ "$use_rsync" = yes ]; then
    if [ "$AUTH" = key ]; then
        RSYNC_SSH="ssh -i $(shq "$KEY_TMP") -o IdentitiesOnly=yes -o BatchMode=yes ${SSH_OPTS[*]}"
        rsync -avP -e "$RSYNC_SSH" "$KERNEL" "$SSH_USER@$IP:$REMOTE_KERNEL"
        rsync -avP -e "$RSYNC_SSH" "$ROOTFS" "$SSH_USER@$IP:$REMOTE_ROOTFS"
    else
        SSHPASS="$PASSWORD" sshpass -e rsync -avP \
            -e "ssh ${SSH_OPTS[*]} -o PreferredAuthentications=password -o PubkeyAuthentication=no" \
            "$KERNEL" "$SSH_USER@$IP:$REMOTE_KERNEL"
        SSHPASS="$PASSWORD" sshpass -e rsync -avP \
            -e "ssh ${SSH_OPTS[*]} -o PreferredAuthentications=password -o PubkeyAuthentication=no" \
            "$ROOTFS" "$SSH_USER@$IP:$REMOTE_ROOTFS"
    fi
else
    scp_to "$KERNEL" "$REMOTE_KERNEL"
    scp_to "$ROOTFS" "$REMOTE_ROOTFS"
fi
scp_to "$ENV_TEMPLATE" "$REMOTE_ENV"

log "verifying remote file sizes"
ssh_run "set -e
[ \$(wc -c < $REMOTE_KERNEL_Q) -eq $KERNEL_SIZE ] || { echo 'kernel size mismatch'; exit 3; }
[ \$(wc -c < $REMOTE_ROOTFS_Q) -eq $ROOTFS_SIZE ] || { echo 'rootfs size mismatch'; exit 3; }
[ -s $REMOTE_ENV_Q ] || { echo 'env_append.txt is empty'; exit 3; }
" || die "remote size verification failed"

log "finalising SD contents"
ssh_run "set -e
cd $SD_MOUNT_Q/boot
mv -f kernel.new kernel
mv -f rootfs.ext4.new rootfs.ext4
sync
cd /
sync
umount $SD_MOUNT_Q
" || die "failed to finalise or unmount the SD card"

ssh_run "fw_setenv update yes
[ \"\$(fw_printenv -n update 2>/dev/null)\" = yes ] || { echo 'failed to arm update'; exit 4; }
" || die "failed to arm the U-Boot update flag"
log "U-Boot update flag armed (update=yes)"

if [ "$REBOOT" = no ]; then
    log "images staged on SD; U-Boot will flash eMMC on the next boot"
    exit 0
fi

log "rebooting the board; U-Boot will flash eMMC and boot the new system"
set +e
ssh_run "sync; (sleep 1; reboot) >/dev/null 2>&1 &"
RC=$?
set -e
[ "$RC" -eq 0 ] || log "ssh returned $RC while rebooting (expected)"

if [ "$WAIT_SEC" -gt 0 ]; then
    log "waiting up to ${WAIT_SEC}s for the board to come back"
    sleep 10
    deadline=$((SECONDS + WAIT_SEC))
    while [ "$SECONDS" -lt "$deadline" ]; do
        if ssh_run_any 'exit 0' >/dev/null 2>&1; then
            log "board is back:"
            ssh_run_any 'uname -r; fw_printenv -n update; ip -4 -br addr show eth0' || true
            exit 0
        fi
        sleep 5
    done
    die "board did not come back within ${WAIT_SEC}s (check serial console)"
fi