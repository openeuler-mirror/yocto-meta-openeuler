#
# \todo: add comments why the following RPEPENDS are required
#   * openeuler uses bind-dhclient to replace bind-utils
#   * inetutils-xxx are not used
#   * debian related tools are not used: debianutils-run-parts dpkg-start-stop
#   * kea is not used
#   * audit, auditd, audispd-plugins are fore secure reasons.
#     kexec-tools for kernel core dump
#
RDEPENDS:${PN} = "\
    base-passwd \
    bash \
    bzip2 \
    coreutils \
    cpio \
    dhcpcd \
    diffutils \
    e2fsprogs \
    file \
    findutils \
    gawk \
    grep \
    gzip \
    ${@bb.utils.contains("DISTRO_FEATURES", "systemd", "", "ifupdown", d)} \
    iproute2 \
    ${@bb.utils.contains("MACHINE_FEATURES", "keyboard", "kbd", "", d)} \
    kmod \
    less \
    ncurses-tools \
    net-tools \
    parted \
    patch \
    procps \
    psmisc \
    sed \
    shadow-base \
    tar \
    time \
    unzip \
    util-linux \
    ${VIRTUAL-RUNTIME_vim} \
    wget \
    which \
    xz \
    audit \
    auditd \
    audispd-plugins \
    cracklib \
    libpwquality \
    libpam \
    packagegroup-pam-plugins \
    kexec-tools \
    openssl-bin \
    cifs-utils \
    curl \
    e2fsprogs-tune2fs \
    expat \
    lvm2 \
    policycoreutils \
    policycoreutils-fixfiles \
    policycoreutils-hll \
    policycoreutils-loadpolicy \
    policycoreutils-semodule \
    policycoreutils-sestatus \
    policycoreutils-setfiles \
    nlopt \
    pstree \
    quota \
    squashfs-tools \
    tzdata-core \
    util-linux-su \
    util-linux-libfdisk \
    expect \
    sysfsutils \
    elfutils \
    json-c \
    libcap-bin \
    libcap-ng-bin \
    libnl-cli \
    libnl-xfrm \
    libpcap \
    libpwquality \
    libselinux-bin \
    libsepol-bin \
    libxml2-utils \
    libusb1 \
    glib-2.0 \
    libbfd \
    ${@bb.utils.contains('DISTRO_FEATURES', 'epkg', 'epkg', '', d)} \
"

# riscv64 arch is not support kexec-tools, view yocto-poky/meta/recipes-kernel/kexec/kexec-tools_2.0.23.bb
# and check COMPATIBLE_HOST param
RDEPENDS:${PN}:remove:riscv64 = "\
    kexec-tools \
"


# for x86-64 arch, add some industrial protocol packages
RDEPENDS:${PN}:append:x86-64 = " \
    ethercat-igh  \
    intel-cmt-cat \
    linuxptp \
"
