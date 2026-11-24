#!/usr/bin/env python3
"""Remote SD-card update for the ZedBoard over the direct USB link.

Uploads the kexec kernel and updater initramfs, switches the board into the
updater, streams a bzip2-compressed wic image over TCP, and waits for the
updater to write it, verify it by sha256 and reboot.

This replaces U-Boot/NFS based provisioning: every connection is initiated
from the host, so the VM keeps its NAT network. If anything goes wrong the
initramfs refuses to touch the card (bad archive) or reports VERIFY FAIL and
keeps waiting; the fallback is always the offline dd flash.

Default is a dry run that validates the whole path (upload, kexec, transfer,
archive) but writes to /dev/null. Pass --write to overwrite the SD card.
"""
import argparse
import bz2
import hashlib
import os
import socket
import subprocess
import sys
import time

SSH_COMMON = ["-F", "/dev/null", "-o", "IdentitiesOnly=yes",
              "-o", "StrictHostKeyChecking=no",
              "-o", "UserKnownHostsFile=/dev/null",
              "-o", "ConnectTimeout=5",
              "-o", "PreferredAuthentications=publickey"]


def ssh_argv(key, board, extra=()):
    return ["ssh"] + SSH_COMMON + ["-i", key, board] + list(extra)


def image_info(path):
    """Return (decompressed size, sha256) of the wic image inside the bz2."""
    h = hashlib.sha256()
    size = 0
    with bz2.open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
            size += len(chunk)
    return size, h.hexdigest()


def retry(fn, tries, delay=2, what="command"):
    last = None
    for _ in range(tries):
        r = fn()
        if r is not None and getattr(r, "returncode", 0) == 0:
            return r
        last = r
        time.sleep(delay)
    return last


def upload(key, board, files):
    for src, dst in files:
        r = subprocess.run(["scp"] + SSH_COMMON + ["-i", key, src,
                                                   f"{board}:{dst}"],
                           capture_output=True, text=True)
        if r.returncode:
            print(f"scp failed for {src}: {r.stderr.strip()}")
            return False
    return True


class SerialLog:
    def __init__(self, device, baud=115200):
        self.port = None
        if not device:
            return
        try:
            import serial
            self.port = serial.Serial(device, baud, timeout=0.3)
            time.sleep(0.2)
            self.port.reset_input_buffer()
        except Exception as exc:  # noqa: BLE001 - console is optional
            print(f"serial disabled ({exc})")

    def wait(self, marker, timeout):
        if not self.port:
            return True
        end = time.time() + timeout
        buf = bytearray()
        while time.time() < end:
            chunk = self.port.read(4096)
            if chunk:
                buf.extend(chunk)
                if marker in bytes(buf):
                    return True
        return False

    def drain_events(self):
        if not self.port:
            return []
        lines = []
        while True:
            chunk = self.port.read(4096)
            if not chunk:
                break
            for line in chunk.decode(errors="replace").splitlines():
                if "[updater]" in line:
                    lines.append(line.strip())
        return lines

    def close(self):
        if self.port:
            self.port.close()


def push_image(image, port=9000, deadline=600):
    data = open(image, "rb").read()
    end = time.time() + deadline
    while time.time() < end:
        try:
            sock = socket.create_connection(("192.168.7.2", port), timeout=5)
        except OSError:
            time.sleep(2)
            continue
        # A timeout here would truncate the transfer and the updater would
        # (correctly) reject the archive; wait as long as the send needs.
        sock.settimeout(None)
        sock.sendall(data)
        sock.shutdown(socket.SHUT_WR)
        sock.close()
        return len(data)
    return 0


def wait_reboot(key, board, timeout):
    """Wait for the board to drop and come back after the updater reboot."""
    end = time.time() + timeout
    saw_down = False
    while time.time() < end:
        r = subprocess.run(ssh_argv(key, board, ["uptime -p"]),
                           capture_output=True, text=True)
        if r.returncode != 0:
            saw_down = True
        elif saw_down:
            return True
        time.sleep(3)
    return False


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--image", required=True, help="openeuler-image-zedboard.wic.bz2")
    p.add_argument("--updater-dir", default="output/zedboard/updater",
                   help="directory with uImage and updater.cpio.gz")
    p.add_argument("--board", default="root@192.168.7.2")
    p.add_argument("--ssh-key", default=os.path.expanduser("~/.ssh/id_ed25519"))
    p.add_argument("--serial", default="/dev/ttyACM0",
                   help="console device for progress, empty to disable")
    p.add_argument("--port", type=int, default=9000)
    p.add_argument("--write", action="store_true",
                   help="actually write the SD card (default: dry run)")
    p.add_argument("--timeout", type=int, default=900,
                   help="seconds to wait for the verified write and reboot")
    args = p.parse_args()

    image = os.path.abspath(args.image)
    kernel = os.path.join(args.updater_dir, "uImage")
    initrd = os.path.join(args.updater_dir, "updater.cpio.gz")
    for f in (image, kernel, initrd):
        if not os.path.isfile(f):
            print(f"missing file: {f}")
            return 1

    size, sha = image_info(image)
    if size % 512:
        print(f"image size {size} is not a multiple of 512")
        return 1
    mode = "WRITE /dev/mmcblk0" if args.write else "dry run (/dev/null)"
    print(f"image {image}: {size} bytes, sha256 {sha}")
    print(f"mode: {mode}")

    if not upload(args.ssh_key, args.board,
                  [(kernel, "/tmp/uImage"), (initrd, "/tmp/updater.cpio.gz")]):
        return 1

    log = SerialLog(args.serial)
    cmdline = (f"console=ttyPS0,115200 net.ifnames=0 rdinit=/init "
               f"upd_dev={'/dev/mmcblk0' if args.write else '/dev/null'} "
               f"upd_size={size} upd_sha={sha} upd_port={args.port} upd_reboot=1")
    load = retry(lambda: subprocess.run(
        ssh_argv(args.ssh_key, args.board, [
            f'kexec -l /tmp/uImage --dtb=/boot/zynq-zed.dtb '
            f'--initrd=/tmp/updater.cpio.gz --command-line="{cmdline}"']),
        capture_output=True, text=True), 10)
    if not load or load.returncode:
        detail = (load.stderr or load.stdout or "").strip() if load else "no response"
        print(f"kexec load failed: {detail}")
        log.close()
        return 1

    subprocess.run(ssh_argv(args.ssh_key, args.board, [
        'nohup sh -c "sleep 1; kexec -e" >/dev/null 2>&1 & echo started']),
        capture_output=True, text=True)

    if log.port and not log.wait(b"[updater] listening", 40):
        print("updater did not start listening")
        log.close()
        return 1
    print("updater running, pushing image")

    sent = push_image(image, args.port)
    if not sent:
        print("could not connect to the updater")
        log.close()
        return 1
    print(f"pushed {sent} bytes")

    marker = b"VERIFY OK" if args.write else b"dry-run stream consumed"
    ok = log.wait(marker, args.timeout) if log.port else True
    for line in log.drain_events():
        print(line)

    if ok and args.write:
        print("waiting for reboot")
        ok = wait_reboot(args.ssh_key, args.board, 180)
        print("board back up" if ok else "board did not come back")

    log.close()
    if not ok:
        print("update NOT verified; keep the card as is and use the offline "
              "flash fallback")
        return 1
    print("OK" if args.write else "dry run OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())