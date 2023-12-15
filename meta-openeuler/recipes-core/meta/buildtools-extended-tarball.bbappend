# openeuler-image-tiny build
TOOLCHAIN_HOST_TASK += "\
    nativesdk-openeuler \
    nativesdk-cpio \
    nativesdk-attr-dev \
    nativesdk-libsqlite3-dev \
    nativesdk-gettext-dev \
    nativesdk-createrepo-c \
    nativesdk-gmp-dev \
    nativesdk-libmpc-dev \
    nativesdk-openssl-dev \
    nativesdk-kmod \
    nativesdk-tzcode \
    nativesdk-elfutils-dev \
    nativesdk-dnf \
    nativesdk-python3-pyyaml \
    nativesdk-diffstat \
"

# openeuler-image build
TOOLCHAIN_HOST_TASK += "\
    nativesdk-meson \
    nativesdk-ninja \
    nativesdk-cracklib \
    nativesdk-bison \
    nativesdk-flex \
    nativesdk-autoconf-archive \
    nativesdk-zlib-dev \
    nativesdk-gtk-doc-dev \
    nativesdk-ldd \
    nativesdk-e2fsprogs-dev \
    nativesdk-util-linux-dev \
    nativesdk-bzip2-dev \
    nativesdk-btrfs-tools \
    nativesdk-squashfs-tools \
    nativesdk-swig \
    nativesdk-libxslt \
    nativesdk-python3-dev \
    nativesdk-intltool \
    nativesdk-tcl \
    nativesdk-glib-2.0-dev \
    nativesdk-dtc-dev \
    nativesdk-unzip \
    nativesdk-patchelf \
    "

# packages required for building graphics
TOOLCHAIN_HOST_TASK += "\
    nativesdk-python3-mako \
    nativesdk-util-macros \
    nativesdk-util-macros-dev \
    nativesdk-xorgproto-dev \
    nativesdk-libxml2-dev \
    nativesdk-expat-dev \
    nativesdk-libxml2-utils \
    nativesdk-libxml2-python \
    nativesdk-itstool \
    nativesdk-pixman-dev \
"

# packages required for build dnf and ros
TOOLCHAIN_HOST_TASK += " \
    nativesdk-qemu \
    nativesdk-qemu-helper \
    nativesdk-glib-2.0-utils \
    nativesdk-glib-2.0-codegen \
    nativesdk-python3-setuptools \
    nativesdk-python3-setuptools-scm \
    nativesdk-python3-cython \
    nativesdk-python3-toml \
    nativesdk-python3-pytest \
    nativesdk-python3-wheel \
"

# this a workaround: Currently, in the CI environment,
# there is a bug in the make operation, which the `realpath xxx_path` in the makefile cannot be executed correctly
# So remove nativesdk-make from the prebuilt tool
TOOLCHAIN_HOST_TASK:remove = "nativesdk-make"
