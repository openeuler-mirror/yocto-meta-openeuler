FROM hub.oepkgs.net/openeuler/openeuler:24.03

# RUN sed -i "s#http://repo.openeuler.org#https://repo.huaweicloud.com/openeuler#g" /etc/yum.repos.d/openEuler.repo

RUN set -eux; \
yum -y install git java tar cmake gperf sqlite-devel libffi-devel xz-devel \
zlib zlib-devel openssl-devel bzip2-devel ncurses-devel readline-devel \
libpcap-devel parted autoconf-archive chrpath gcc-c++ patch rpm-build flex \
autoconf automake m4 bison bc libtool gettext-devel createrepo_c net-tools \
wget sudo hostname rpcgen texinfo python meson dosfstools mtools libmpc-devel \
gmp-devel ninja-build numactl-devel make python3 python3-pip screen glibc-locale-archive \
iproute xz unzip help2man libstdc++-static gcc g++ rsync python3-devel gdisk umoci skopeo \
libxslt vim hwdata perl-XML-Parser iptables golang quilt

RUN wget https://repo.oepkgs.net/openeuler/rpm/openEuler-20.03-LTS-SP1/compatible/c7/x86_64/Packages/git-lfs-2.10.0-1.x86_64.rpm
RUN rpm -ivh git-lfs-2.10.0-1.x86_64.rpm && rm -f git-lfs-2.10.0-1.x86_64.rpm

ARG user=openeuler
ARG group=openeuler
ARG uid=1000
ARG gid=1000

# add build user
RUN groupadd -g ${gid} ${group} && useradd -c "${user}" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# modify /usr1 owner
RUN mkdir -p /usr1 && chown -R ${user}:${group} /usr1 /opt && chmod -R 755 /usr1 /opt

# install nativesdk toolchains and environment of build toolchains
# notice: nativesdk and toolchains is for building OS

# modify default configs
RUN sed -i 's/TMOUT=300/TMOUT=/g' /etc/bashrc

# add umask conf to 022 in file /etc/bashrc
RUN echo "umask 022" >> /etc/bashrc

USER openeuler

ARG openeuler_repo=https://gitee.com/openeuler/yocto-meta-openeuler
ARG openeuler_base_version=24.03-LTS

# download nativesdk release and install it
ARG nativesdk_version=v0.1.2
ARG nativesdk_name=x86_64-buildtools-extended-nativesdk-standalone
RUN mkdir -p /opt/buildtools/nativesdk/sdk_info
WORKDIR /opt/buildtools/nativesdk/sdk_info
RUN wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}-${openeuler_base_version}.testdata.json \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/1_${nativesdk_name}-${openeuler_base_version}.sh \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/2_${nativesdk_name}-${openeuler_base_version}.sh \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/3_${nativesdk_name}-${openeuler_base_version}.sh \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}-${openeuler_base_version}.target.manifest \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}-${openeuler_base_version}.host.manifest \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/merge_data.sh \
    && bash ./merge_data.sh
RUN ./${nativesdk_name}-${openeuler_base_version}.sh -d /opt/buildtools/nativesdk -y
RUN . /opt/buildtools/nativesdk/environment-setup-x86_64-openeulersdk-linux

# download toolchain release and install it
ARG toolchain_version=toolchains-v0.1.5
RUN mkdir -p /usr1/openeuler/gcc
WORKDIR /usr1/openeuler/gcc
RUN wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/4_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/4_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/1_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/2_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/3_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/${toolchain_version}/merge_data.sh \
    && bash ./merge_data.sh \
    && tar xzvf openeuler_gcc_arm64le.tar.gz \
    && rm -rf openeuler_gcc_arm64le.tar.gz \
    && tar xzvf openeuler_gcc_x86_64.tar.gz \
    && rm -rf openeuler_gcc_x86_64.tar.gz \
    && tar xzvf openeuler_gcc_arm32le.tar.gz \
    && rm -rf openeuler_gcc_arm32le.tar.gz \
    && tar xzvf openeuler_gcc_riscv64.tar.gz \
    && rm -rf openeuler_gcc_riscv64.tar.gz \
    && rm -rf merge_data.sh

# give write authority to gcc
RUN chmod u+w -R ./*

WORKDIR /usr1/openeuler
# download llvm toolchain and install it
ARG llvm_toolchain_version=llvm-toolchain-v0.1.1
RUN wget ${openeuler_repo}/releases/download/${llvm_toolchain_version}/1_clang-llvm-17.0.6.tar.gz \
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
    && sudo rm -rf clang-llvm-17.0.6.tar.gz merge_data.sh

RUN sudo chmod -R 777 /opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/var/

WORKDIR /home/${user}

RUN rm -rf /opt/buildtools/nativesdk/sdk_info
# install necessary python package because Optee-os need this package involve during compile
RUN pip3 install cryptography -i https://pypi.tuna.tsinghua.edu.cn/simple
