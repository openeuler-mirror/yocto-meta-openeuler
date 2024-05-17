FROM openeuler/openeuler:23.09

# RUN sed -i "s#http://repo.openeuler.org#https://repo.huaweicloud.com/openeuler#g" /etc/yum.repos.d/openEuler.repo

RUN set -eux; \
yum -y install git java tar cmake gperf sqlite-devel libffi-devel xz-devel \
zlib zlib-devel openssl-devel bzip2-devel ncurses-devel readline-devel \
libpcap-devel parted autoconf-archive chrpath gcc-c++ patch rpm-build flex \
autoconf automake m4 bison bc libtool gettext-devel createrepo_c net-tools \
wget sudo hostname rpcgen texinfo python meson dosfstools mtools libmpc-devel \
gmp-devel ninja-build numactl-devel make python3 python3-pip screen glibc-locale-archive \
iproute xz unzip help2man libstdc++-static gcc g++ rsync python3-devel gdisk umoci skopeo \
libxslt vim hwdata perl-XML-Parser

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
ARG toolchain_version=v0.1.4
RUN mkdir -p /usr1/openeuler/gcc
WORKDIR /usr1/openeuler/gcc
RUN wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/1_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/2_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/3_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/4_openeuler_gcc_arm64le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/1_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/2_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/3_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/4_openeuler_gcc_x86_64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/1_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/2_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/3_openeuler_gcc_arm32le.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/1_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/2_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/3_openeuler_gcc_riscv64.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchains-${toolchain_version}/merge_data.sh \
    && bash ./merge_data.sh
# deal aarch64 toolchain
RUN tar xzvf openeuler_gcc_arm64le.tar.gz &&  \
    rm -rf openeuler_gcc_arm64le.tar.gz
# deal x86_64 toolchain
RUN tar xzvf openeuler_gcc_x86_64.tar.gz &&  \
    rm -rf openeuler_gcc_x86_64.tar.gz
# deal arm toolchain
RUN tar xzvf openeuler_gcc_arm32le.tar.gz &&  \
    rm -rf openeuler_gcc_arm32le.tar.gz
# deal riscv64 toolchain
RUN tar xzvf openeuler_gcc_riscv64.tar.gz &&  \
    rm -rf openeuler_gcc_riscv64.tar.gz
RUN rm -rf merge_data.sh

RUN sudo chmod -R 777 /opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/var/

WORKDIR /home/${user}

RUN rm -rf /opt/buildtools/nativesdk/sdk_info
