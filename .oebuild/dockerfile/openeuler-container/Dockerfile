FROM hub.oepkgs.net/openeuler/openeuler:24.03

# RUN sed -i "s#http://repo.openeuler.org#https://repo.huaweicloud.com/openeuler#g" /etc/yum.repos.d/openEuler.repo

# install build dependencies and git-lfs, then clean caches in a single layer
RUN set -eux; \
    yum -y install --setopt=install_weak_deps=False --setopt=tsflags=nodocs \
        git java tar cmake gperf sqlite-devel libffi-devel xz-devel \
        zlib zlib-devel openssl-devel bzip2-devel ncurses-devel readline-devel \
        libpcap-devel parted autoconf-archive chrpath gcc-c++ patch rpm-build flex \
        autoconf automake m4 bison bc libtool gettext-devel createrepo_c net-tools \
        wget sudo hostname rpcgen texinfo python meson dosfstools mtools libmpc-devel \
        gmp-devel ninja-build numactl-devel make python3 python3-pip screen glibc-locale-archive \
        iproute xz unzip help2man libstdc++-static gcc g++ rsync python3-devel gdisk umoci skopeo \
        libxslt vim hwdata perl-XML-Parser iptables golang quilt; \
    wget -P /tmp https://repo.oepkgs.net/openeuler/rpm/openEuler-20.03-LTS-SP1/compatible/c7/x86_64/Packages/git-lfs-2.10.0-1.x86_64.rpm; \
    rpm -ivh /tmp/git-lfs-2.10.0-1.x86_64.rpm && rm -f /tmp/git-lfs-2.10.0-1.x86_64.rpm; \
    yum clean all; \
    rm -rf /var/cache/yum /var/cache/dnf /var/lib/rpm/__db* /tmp/* /var/tmp/*

ARG user=openeuler
ARG group=openeuler
ARG uid=1000
ARG gid=1000

# add build user, configure sudo, dirs and shell configs in a single layer
RUN groupadd -g ${gid} ${group} && useradd -c "${user}" -d /home/${user} -u ${uid} -g ${gid} -m ${user} \
    && echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir -p /usr1 && chown -R ${user}:${group} /usr1 /opt && chmod -R 755 /usr1 /opt \
    && sed -i 's/TMOUT=300/TMOUT=/g' /etc/bashrc \
    && echo "umask 022" >> /etc/bashrc \
    && chmod 777 /var/log/hawkey.log && mkdir -p /var/cache/dnf && chmod -R 777 /var/cache/dnf

USER openeuler

ARG openeuler_repo=https://atomgit.com/openeuler/yocto-meta-openeuler
ARG openeuler_base_version=latest

# download, install and clean nativesdk in a single layer
ARG nativesdk_version=v0.1.3
ARG nativesdk_name=x86_64-buildtools-extended-nativesdk-standalone
RUN mkdir -p /opt/buildtools/nativesdk/sdk_info
WORKDIR /opt/buildtools/nativesdk/sdk_info
RUN set -eux; \
    wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}-${openeuler_base_version}.testdata.json \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/1_${nativesdk_name}-${openeuler_base_version}.sh \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/2_${nativesdk_name}-${openeuler_base_version}.sh \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/3_${nativesdk_name}-${openeuler_base_version}.sh \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}-${openeuler_base_version}.target.manifest \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}-${openeuler_base_version}.host.manifest \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/merge_data.sh \
    && bash ./merge_data.sh \
    && ./${nativesdk_name}-${openeuler_base_version}.sh -d /opt/buildtools/nativesdk -y \
    && . /opt/buildtools/nativesdk/environment-setup-x86_64-openeulersdk-linux \
    && rm -rf /opt/buildtools/nativesdk/sdk_info

# download, install and clean gcc toolchains in a single layer
ARG toolchain_version=toolchains-v0.1.8
RUN mkdir -p /usr1/openeuler/gcc
WORKDIR /usr1/openeuler/gcc
RUN set -eux; \
    wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_arm32le-musl.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_arm32le-musl.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_arm32le-musl.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/4_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/4_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/merge_data.sh \
    && bash ./merge_data.sh \
    && tar xzf openeuler_gcc_arm64le.tar.gz && rm -f openeuler_gcc_arm64le.tar.gz \
    && tar xzf openeuler_gcc_x86_64.tar.gz && rm -f openeuler_gcc_x86_64.tar.gz \
    && tar xzf openeuler_gcc_arm32le.tar.gz && rm -f openeuler_gcc_arm32le.tar.gz \
    && tar xzf openeuler_gcc_arm32le-musl.tar.gz && rm -f openeuler_gcc_arm32le-musl.tar.gz \
    && tar xzf openeuler_gcc_riscv64.tar.gz && rm -f openeuler_gcc_riscv64.tar.gz \
    && rm -f [0-9]_*.tar.gz merge_data.sh; \
    chmod u+w -R ./*

# download, install and clean llvm toolchain in a single layer
ARG llvm_toolchain_version=llvm-toolchain-v0.1.1
RUN mkdir -p /usr1/openeuler
WORKDIR /usr1/openeuler
RUN set -eux; \
    wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/1_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/2_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/3_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/4_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/5_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/6_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/7_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/8_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/9_clang-llvm-17.0.6.tar.gz \
    && wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/merge_data.sh \
    && bash ./merge_data.sh \
    && tar zxf clang-llvm-17.0.6.tar.gz \
    && sudo mv clang-llvm-17.0.6 llvm \
    && sudo rm -rf clang-llvm-17.0.6.tar.gz [0-9]_clang-llvm-17.0.6.tar.gz merge_data.sh

# download, install and clean llvm-musl-arm toolchain
ARG llvm_musl_arm_version=arm32-clang-musl-toolchain-v0.1.0
WORKDIR /usr1/openeuler
RUN set -eux; \
    wget ${openeuler_repo}/releases/download/${llvm_musl_arm_version}/llvm-musl-arm.tar.gz \
    && tar zxf llvm-musl-arm.tar.gz \
    && rm -f llvm-musl-arm.tar.gz

WORKDIR /home/${user}

# fix nativesdk var perms and install python package without caching
RUN sudo chmod -R 777 /opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/var/ \
    && pip3 install --no-cache-dir cryptography pyyaml GitPython -i https://pypi.tuna.tsinghua.edu.cn/simple
