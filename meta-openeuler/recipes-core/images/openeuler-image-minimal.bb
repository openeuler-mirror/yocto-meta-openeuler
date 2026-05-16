SUMMARY = "Minimal runnable openEuler image: C library + busybox + network"

# No extra IMAGE_FEATURES — bare minimum
IMAGE_FEATURES = "empty-root-password"

include recipes-core/images/image-early-config-${MACHINE}.inc
require openeuler-image-common.inc

# not build sdk
deltask populate_sdk

# PACKAGE_INSTALL directly controls rootfs contents.
# TCLIBC selects the C library: "glibc" (default, external toolchain) or "musl".
PACKAGE_INSTALL = " \
    kernel-img \
    busybox \
    ${TCLIBC} \
"

# No feature packages (no ssh, no debug tools)
FEATURE_INSTALL = ""
# No extra users
EXTRA_USERS_PARAMS = ""

# Console TTY for inittab — extracted from SERIAL_CONSOLES (format: "<baud>;<tty>"),
# falling back to ttyAMA0 (qemu-aarch64 PL011 UART).
IMAGE_MINIMAL_CONSOLE = "${@((d.getVar('SERIAL_CONSOLES') or '115200;ttyAMA0').split()[0]).split(';')[-1]}"

setup_minimal_rootfs() {
    cd "${IMAGE_ROOTFS}"

    # Ensure standard mount points exist
    mkdir -p dev proc sys tmp run

    # Clear and rebuild /etc with minimal configuration
    rm -rf etc/*
    mkdir -p etc/init.d

    # inittab: only sysinit + one login shell on the serial console.
    # Using an explicit inittab avoids busybox init's built-in default,
    # which spawns shells on tty2/tty3/tty4 — virtual consoles that
    # don't exist in QEMU nographic mode, causing a tight respawn loop.
    cat > etc/inittab <<INITTABEOF
::sysinit:/etc/init.d/rcS
${IMAGE_MINIMAL_CONSOLE}::respawn:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
INITTABEOF

    # Startup script: mount filesystems, populate /dev, configure network
    cat > etc/init.d/rcS <<'RCEOF'
#!/bin/sh

# Mount filesystems listed in /etc/fstab
/bin/mount -a
mount -o remount,rw /

# Set up /dev/pts for pseudo-terminals
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

# Populate /dev nodes via mdev
mdev -s

# Bring up loopback interface
ifconfig lo 127.0.0.1 up

# Bring up eth0 and obtain IP via DHCP (best-effort, non-fatal)
ifconfig eth0 up 2>/dev/null
udhcpc -i eth0 -q -n 2>/dev/null || true
RCEOF
    chmod +x etc/init.d/rcS

    cat > etc/fstab <<'FSTABEOF'
proc    /proc   proc    defaults    0   0
tmpfs   /tmp    tmpfs   defaults    0   0
sysfs   /sys    sysfs   defaults    0   0
FSTABEOF

    cat > etc/profile <<'PROFEOF'
# /etc/profile: system-wide .profile file for the Bourne shells

echo
echo -n "Processing /etc/profile... "
echo "Done"
echo
PROFEOF

    # busybox installs linuxrc in some configurations; prefer /init
    if [ -f linuxrc ]; then
        mv linuxrc init
    fi

    cd -
}
IMAGE_PREPROCESS_COMMAND += "setup_minimal_rootfs;"
