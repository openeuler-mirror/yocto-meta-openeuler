# to save initial build time, unnecessary software dependecy, openeuler embedded will
# use as many as possible prebuild nativesdk/host tools to replace native tools.
# this file has related HOSTTOOLS and ASSUME_PROVIDED settings.

# basic tools
HOSTTOOLS += "python3 python pod2man gnu-configize pkg-config"
ASSUME_PROVIDED += "python3-native python3-setuptools-native pkgconfig-native chrpath-replacement-native"

# package management tools
HOSTTOOLS += "rpmbuild createrepo_c dnf"
ASSUME_PROVIDED += "rpm-native createrepo-c-native"

# commands used by kernel build
HOSTTOOLS += "flex bison bc"
ASSUME_PROVIDED += "bc-native bison-native flex-native kmod-native"

# autotools related tools
HOSTTOOLS += "automake autoreconf aclocal libtoolize m4 autoconf autoheader automake-1.16 aclocal-1.16 \
              libtool autopoint autoscan autom4te autoupdate"
ASSUME_PROVIDED += "automake-native autoconf-native libtool-native m4-native"

# source file build tools
HOSTTOOLS += "cmake ninja meson"
ASSUME_PROVIDED += "cmake-native ninja-native meson-native make-native"

# used by cracklib, built from cracklib-native
HOSTTOOLS_NONFATAL += "create-cracklib-dict cracklib-format cracklib-packer cracklib-unpacker"

# commands for create image
HOSTTOOLS += "ldconfig"
ASSUME_PROVIDED +="ldconfig-native "

# compress and uncompress tools
HOSTTOOLS_NONFATAL += "xz"
ASSUME_PROVIDED += "xz-native pigz-native gzip-native"


# gettext amd documentation related tools
HOSTTOOLS_NONFATAL += "msgfmt msgmerge makeinfo"
ASSUME_PROVIDED += "gettext-native texinfo-dummy-native"

HOSTTOOLS_NONFATAL += "rpcgen"

##commands used by raspberrrypi4 specially
HOSTTOOLS_NONFATAL_append_raspberrypi4 += "mkdosfs mcopy mkfs.ext4 debugfs fsck.ext4 dumpe2fs \
                                           parted mkfs.vfat mmd"
ASSUME_PROVIDED += "parted-native dosfstools-native  mtools-native bmap-tools-native gptfdisk-native"

# graphics related
ASSUME_PROVIDED +=  "pixman-native mesa-native virglrenderer-native libsdl2-native"

# audio related
ASSUME_PROVIDED += "alsa-lib-native"

#some commands added in poky by default do not used now, make it optional
HOSTTOOLS_remove += "diffstat lz4c pzstd"
HOSTTOOLS_NONFATAL += "diffstat lz4c pzstd"

SANITY_REQUIRED_UTILITIES_remove += "diffstat chrpath"
CONNECTIVITY_CHECK_URIS = ""

# Misc. assume provided software package
# tic used by ncurses-native
# zic used by tzdata(tzcode-native)
HOSTTOOLS_NONFATAL += "fmt gperf tic zic"

# the following are used to remove dependency
## tools required possibly required by linux-libc-hearders
ASSUME_PROVIDED += "unifdef-native rsync-native"
## prebuilt qemu is used, so no qemu-native and nativesdk-qemuwrapper-cross
ASSUME_PROVIDED += "qemu-native rsync-native nativesdk-qemuwrapper-cross"
## dwarfsrcfiles-native is used in package.bbclass, it needs elfutil
## \todo remove dwarfsrcfiles-native after elfutil is added into nativesdk
ASSUME_PROVIDED += "dwarfsrcfiles-native"

# used by libpam
ASSUME_PROVIDED += "libxml2-native"
# used by make-mod-scripts
ASSUME_PROVIDED += "gmp-native"
# used by cracklib
ASSUME_PROVIDED += "cracklib-native"

ASSUME_PROVIDED += "gperf-native perl-native  \
                    init-system-helpers \
                    cross-localedef-native nativesdk-glibc-locale \
                    openssl-native ncurses-native \
                    gtk-doc-native \
                    "
