SUMMARY = "Externally built firmware for the MCS client OS"
DESCRIPTION = "Installs the ELF image and the optional raw binary produced by \
a firmware build that runs outside of Yocto. The firmware may come from any \
RTOS or baremetal project, Zephyr is only the reference implementation, as \
long as it implements the MCS client interface: an OpenAMP resource table \
and the rpmsg endpoints used by micad."
HOMEPAGE = "https://gitee.com/openeuler/mcs"
# The firmware is built outside of the layer, so its license is not known
# here. Override this in local.conf when the client firmware has one.
LICENSE ?= "CLOSED"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# Absolute path of the client ELF built outside of Yocto, for example
# builds/qemu_mcs_remote/zephyr/zephyr.elf in a Zephyr workspace. It must
# also be visible inside the oebuild container. Set it in local.conf or in
# the sample yaml.
MCS_FIRMWARE_ELF ?= ""

# Optional raw image of the same firmware. Xen takes the client OS as its
# kernel and needs the binary rather than the ELF, so set this when the
# client is booted by Xen. Both paths must be visible in the container.
MCS_FIRMWARE_BIN ?= ""

# Basename installed under /lib/firmware. The mica client configuration, the
# Xen domain configuration and the jailhouse cell configuration must use the
# same name. The default keeps the Zephyr file names used by the shipped
# configs; other clients normally set their own name.
MCS_FIRMWARE_NAME ?= "zephyr"

def mcs_firmware_uris(d):
    uris = []
    for var in ("MCS_FIRMWARE_ELF", "MCS_FIRMWARE_BIN"):
        path = d.getVar(var)
        if path:
            uris.append("file://%s" % path)
    return " ".join(uris)

# Keep SRC_URI empty when neither variable is set: a bare "file://" makes
# openeuler.bbclass's checksum expansion fail while parsing machines that
# do not use external-firmware.
SRC_URI = "${@mcs_firmware_uris(d)}"

S = "${WORKDIR}"

python validate_mcs_firmware() {
    import os
    import re

    def check_abs(file_path, var):
        if not os.path.isabs(file_path):
            bb.fatal("%s must be an absolute path, got '%s'" % (var, file_path))
        if not os.path.exists(file_path):
            bb.fatal("%s '%s' does not exist, build the firmware "
                     "and make sure it is mounted into the build container"
                     % (var, file_path))

    elf = d.getVar("MCS_FIRMWARE_ELF")
    if not elf:
        bb.fatal("MCS_FIRMWARE_ELF is not set, point it to the client ELF "
                 "produced by the external build")
    check_abs(elf, "MCS_FIRMWARE_ELF")

    bin_path = d.getVar("MCS_FIRMWARE_BIN")
    if bin_path:
        check_abs(bin_path, "MCS_FIRMWARE_BIN")

    name = d.getVar("MCS_FIRMWARE_NAME")
    if not name or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", name):
        bb.fatal("MCS_FIRMWARE_NAME must be a plain file name, got '%s'" % name)
}
do_fetch[prefuncs] += "validate_mcs_firmware"

do_install() {
    # base_do_unpack mirrors the absolute file:// path below WORKDIR
    # instead of dropping the plain file at the top of it.
    install -D -m 0644 \
        ${WORKDIR}${MCS_FIRMWARE_ELF} \
        ${D}${nonarch_base_libdir}/firmware/${MCS_FIRMWARE_NAME}.elf
    if [ -n "${MCS_FIRMWARE_BIN}" ]; then
        install -D -m 0644 \
            ${WORKDIR}${MCS_FIRMWARE_BIN} \
            ${D}${nonarch_base_libdir}/firmware/${MCS_FIRMWARE_NAME}.bin
    fi
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/${MCS_FIRMWARE_NAME}.elf ${nonarch_base_libdir}/firmware/${MCS_FIRMWARE_NAME}.bin"
INSANE_SKIP:${PN} += "already-stripped"
