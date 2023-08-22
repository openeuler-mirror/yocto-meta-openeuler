# to save initial build time, remove unnecessary software dependency, openeuler embedded will
# use as many as possible prebuilt nativesdk/host tools to replace native tools.
# this file has related HOSTTOOLS and ASSUME_PROVIDED settings.

HOSTTOOLS:remove = "chrpath cpp rpcgen"
HOSTTOOLS_NONFATAL += "chrpath cpp rpcgen"
# basic tools
HOSTTOOLS += "python3 python pod2man pkg-config"
HOSTTOOLS_NONFATAL += "gnu-configize"
# used by perl-native
HOSTTOOLS_NONFATAL += "cc"
ASSUME_PROVIDED += "util-linux-native pkgconfig-native chrpath-replacement-native"

# package management tools
HOSTTOOLS_NONFATAL += "rpm rpmbuild createrepo_c dnf unzip rpm2cpio"
ASSUME_PROVIDED += "rpm-native createrepo-c-native unzip-native"

# commands used by kernel build
HOSTTOOLS_NONFATAL += "flex bison bc kmod depmod insmod"
ASSUME_PROVIDED += "bc-native bison-native flex-native kmod-native"

# autotools related tools
HOSTTOOLS_NONFATAL += "automake autoreconf aclocal libtoolize m4 autoconf autoheader automake-1.16 aclocal-1.16 \
              libtool autopoint autoscan autom4te autoupdate"
ASSUME_PROVIDED += "automake-native autoconf-native libtool-native m4-native"

# source file build tools
HOSTTOOLS_NONFATAL += "cmake ninja"
ASSUME_PROVIDED += "cmake-native ninja-native make-native"

# used by cracklib, built from cracklib-native
HOSTTOOLS_NONFATAL += "create-cracklib-dict cracklib-format cracklib-packer cracklib-unpacker"

# commands for create image
HOSTTOOLS_NONFATAL += "ldconfig"
ASSUME_PROVIDED +="ldconfig-native "

# compress and decompress tools
HOSTTOOLS_NONFATAL += "xz"
ASSUME_PROVIDED += " pigz-native gzip-native"


# gettext amd documentation related tools
HOSTTOOLS_NONFATAL += "msgfmt msgmerge makeinfo xgettext"
ASSUME_PROVIDED += "texinfo-dummy-native gettext-native"

# openssl tools 
# temporarily remove openssl nativesdk and use openssl-native for bugs (cmake not found)
# HOSTTOOLS_NONFATAL += "openssl"

# command from glib2 used by gobject-introspection and libdnf
HOSTTOOLS_NONFATAL += "gtkdocize gtkdoc-scan gtkdoc-scangobj gtkdoc-mkdb gtkdoc-mkhtml gtkdoc-fixxref"

# commands used by iso and wic
HOSTTOOLS_NONFATAL += "cpio mkdosfs mcopy mkfs.ext4 debugfs fsck.ext4 dumpe2fs parted mkfs.vfat mmd"
ASSUME_PROVIDED += "cpio-native parted-native dosfstools-native  mtools-native bmap-tools-native gptfdisk-native"

# graphics related
ASSUME_PROVIDED +=  "pixman-native mesa-native virglrenderer-native libsdl2-native"

# audio related
ASSUME_PROVIDED += "alsa-lib-native"

#some commands added in poky by default do not used now, make it optional
HOSTTOOLS:remove = "diffstat lz4c pzstd"
HOSTTOOLS_NONFATAL += "diffstat lz4c pzstd"

SANITY_REQUIRED_UTILITIES:remove = "diffstat chrpath"
CONNECTIVITY_CHECK_URIS = ""

# Misc. assume provided software package
# tic used by ncurses-native
# zic used by tzdata(tzcode-native)
HOSTTOOLS_NONFATAL += "fmt gperf tic zic"

# the following are used to remove dependency
## tools required possibly required by linux-libc-hearders
ASSUME_PROVIDED += "unifdef-native rsync-native"
## prebuilt qemu is used (gobject-introspection), so no qemu-native and nativesdk-qemuwrapper-cross
ASSUME_PROVIDED += "qemu-native rsync-native nativesdk-qemuwrapper-cross"
HOSTTOOLS_NONFATAL += "qemu-aarch64 qemu-arm qemu-i386 qemu-ppc qemu-ppc64 qemu-pr-helper qemu-riscv32 qemu-riscv64 generic-x86_64 qemu-x86_64"
## dwarfsrcfiles-native is used in package.bbclass, it needs elfutil
## \todo remove dwarfsrcfiles-native after elfutil is added into nativesdk
ASSUME_PROVIDED += "dwarfsrcfiles-native"

# used by libpam
ASSUME_PROVIDED += "attr-native"
# used by make-mod-scripts
ASSUME_PROVIDED += "gmp-native"
# used by cracklib
ASSUME_PROVIDED += "cracklib-native"
# used by glib-2.0
ASSUME_PROVIDED += "glib-2.0-native"
# used by libarchive
ASSUME_PROVIDED += "e2fsprogs-native"
ASSUME_PROVIDED += "file-native"
# used by binutils
ASSUME_PROVIDED += "gnu-config-native"

ASSUME_PROVIDED += "gperf-native perl-native \
                    init-system-helpers \
                    nativesdk-glibc-locale \
                    gtk-doc-native \
                    "

HOSTTOOLS_NONFATAL += "dtc"
ASSUME_PROVIDED += "intltool-native"

# used by wayland
ASSUME_PROVIDED += "xorgproto-native expat-native"

# used by tcl
ASSUME_PROVIDED += "tcl-native"

# used by python3
# remove ASSUME_PROVIDED of openssl-native zlib-native for cmake not found bugs
ASSUME_PROVIDED += "bzip2-replacement-native libffi-native sqlite3-native \
        xz-native libtirpc-native libnsl2-native autoconf-archive-native \
        gdbm-native readline-native"

# used by harfbuzz
HOSTTOOLS_NONFATAL += "glib-mkenums"

# used by gstreamer1.0
HOSTTOOLS_NONFATAL += "xgettext"
