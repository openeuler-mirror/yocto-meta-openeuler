# Cross-compilation toolchain build container
#
# Provides dual GCC versions for all cross-compilation toolchain builds:
#   - GCC 7.3.0 (system default, for ct-ng cross-toolchain builds)
#   - crosstool-NG 1.26.0
#   - GCC 12.4.0 at /opt/gcc-12 (for LLVM/Clang builds, requires GCC >= 7.4)
#   - cmake 3.27.9 (for LLVM 17/19)
#   - ninja 1.11.1 (for LLVM build system)
#
# GCC version selection:
#   - GCC cross-toolchain (ct-ng): use default gcc (7.3.0)
#   - LLVM/Clang: set CC=gcc-12 CXX=g++-12
#
# Build:
#   cd .oebuild/dockerfile/openeuler-sdk
#   docker build -t openeuler-sdk:latest .

FROM hub.oepkgs.net/openeuler/openeuler:20.03

# Install build dependencies
RUN set -eux; \
    yum -y install git java tar binutils-devel gperf sqlite-devel libffi-devel xz-devel \
    zlib zlib-devel openssl-devel bzip2-devel ncurses-devel readline-devel \
    libpcap-devel parted autoconf-archive chrpath gcc-c++ patch rpm-build flex \
    autoconf automake m4 bison bc libtool gettext-devel createrepo_c net-tools \
    wget sudo hostname rpcgen texinfo meson dosfstools mtools libmpc-devel \
    gmp-devel ninja-build numactl-devel make python python3 python3-pip screen \
    iproute help2man gdisk libstdc++-static diffstat lzip python3-devel rsync \
    xz-lzma-compat xz unzip gcc gcc-c++ vim hwdata libxslt perl-XML-Parser umoci skopeo; \
    yum clean packages

ARG user=openeuler
ARG group=openeuler
ARG uid=1000
ARG gid=1000

# Add build user, configure sudo, dirs and shell configs
RUN groupadd -g ${gid} ${group} && useradd -c "${user}" -d /home/${user} -u ${uid} -g ${gid} -m ${user} \
    && echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir -p /usr1 && chown -R ${user}:${group} /usr1 /opt && chmod -R 755 /usr1 /opt \
    && sed -i 's/TMOUT=300/TMOUT=/g' /etc/bashrc

# Configure pip to use Tsinghua mirror
RUN printf '[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\ntrusted-host = pypi.tuna.tsinghua.edu.cn\n' > /etc/pip.conf

# Install cmake 3.27.9 and ninja 1.11.1 via pip (overrides system cmake)
RUN pip3 install cmake==3.27.9 ninja==1.11.1

# Download and build crosstool-NG 1.26.0
WORKDIR /home/${user}
RUN set -eux; \
    wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2 \
    && tar jxvf crosstool-ng-1.26.0.tar.bz2 \
    && cd crosstool-ng-1.26.0 && ./configure && make && make install \
    && cd /home/${user} && rm -rf crosstool-ng-1.26.0 crosstool-ng-1.26.0.tar.bz2

# Build and install GCC 12.4.0 from source (bootstrapped with system GCC 7.3.0)
# Installed to /opt/gcc-12, coexists with system GCC 7.3.0
ARG gcc_version=12.4.0
RUN set -eux; \
    cd /tmp && \
    wget -q https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz && \
    tar xf gcc-${gcc_version}.tar.xz && \
    mkdir build-gcc12 && cd build-gcc12 && \
    /tmp/gcc-${gcc_version}/configure \
      --prefix=/opt/gcc-12 \
      --enable-languages=c,c++ \
      --disable-multilib \
      --disable-nls \
      --disable-bootstrap \
      --disable-werror && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/gcc-${gcc_version} /tmp/build-gcc12 /tmp/gcc-${gcc_version}.tar.xz

# Create GCC 12 wrapper scripts (gcc-12/g++-12 alongside default gcc/g++)
RUN ln -sf /opt/gcc-12/bin/gcc /usr/local/bin/gcc-12 && \
    ln -sf /opt/gcc-12/bin/g++ /usr/local/bin/g++-12 && \
    ln -sf /opt/gcc-12/bin/gcc-ar /usr/local/bin/gcc-ar-12 && \
    ln -sf /opt/gcc-12/bin/gcc-nm /usr/local/bin/gcc-nm-12 && \
    ln -sf /opt/gcc-12/bin/gcc-ranlib /usr/local/bin/gcc-ranlib-12 && \
    ln -sf /opt/gcc-12/bin/gcov /usr/local/bin/gcov-12

# Add GCC 12 library path for runtime linking
RUN printf '/opt/gcc-12/lib64\n/opt/gcc-12/lib\n' > /etc/ld.so.conf.d/gcc-12.conf && \
    ldconfig

USER ${user}
WORKDIR /home/${user}

# Verify all tools are available
RUN gcc --version | head -1 && \
    gcc-12 --version | head -1 && \
    g++-12 --version | head -1 && \
    cmake --version | head -1 && \
    ninja --version && \
    ct-ng version | head -2 | tail -1
