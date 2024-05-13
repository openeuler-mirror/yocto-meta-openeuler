FROM openeuler/openeuler:23.09

# RUN sed -i "s#http://repo.openeuler.org#https://repo.huaweicloud.com/openeuler#g" /etc/yum.repos.d/openEuler.repo

RUN set -eux; \
yum -y install git java tar cmake gperf sqlite-devel libffi-devel xz-devel \
zlib zlib-devel openssl-devel bzip2-devel ncurses-devel readline-devel \
libpcap-devel parted autoconf-archive chrpath gcc-c++ patch rpm-build flex \
autoconf automake m4 bison bc libtool gettext-devel createrepo_c net-tools \
wget sudo hostname rpcgen texinfo python meson dosfstools mtools libmpc-devel \
gmp-devel ninja-build numactl-devel make python3 python3-pip screen glibc-locale-archive iproute \
xz unzip help2man libstdc++-static gcc g++ rsync python3-devel gdisk

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
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/${nativesdk_name}e-${openeuler_base_version}.host.manifest \
    && wget ${openeuler_repo}/releases/download/nativesdk-${nativesdk_version}/merge_data.sh \
    && bash ./merge_data.sh
RUN ./${nativesdk_name}-${openeuler_base_version}.sh -d /opt/buildtools/nativesdk -y
RUN . /opt/buildtools/nativesdk/environment-setup-x86_64-openeulersdk-linux
RUN rm -rf /opt/buildtools/nativesdk/sdk_info

# download toolchain release and install it
ARG toolchain_version=v0.1.3
RUN mkdir -p /usr1/openeuler/gcc
WORKDIR /usr1/openeuler/gcc
RUN wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/1_aarch64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/2_aarch64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/3_aarch64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/4_aarch64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/1_x86_64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/2_x86_64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/3_x86_64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/4_x86_64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/1_arm-openeuler-linux-gnueabi.tar.gz \
    && wget ${openeuler_repo}releases/download/toolchians-${toolchain_version}/2_arm-openeuler-linux-gnueabi.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/3_arm-openeuler-linux-gnueabi.tar.gz \
    && wget ${openeuler_repo}releases/download/toolchians-${toolchain_version}/1_riscv64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/2_riscv64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/3_riscv64-openeuler-linux-gnu.tar.gz \
    && wget ${openeuler_repo}/releases/download/toolchians-${toolchain_version}/merge_data.sh \
    && bash ./merge_data.sh
# deal aarch64 toolchain
RUN tar xzvf aarch64-openeuler-linux-gnu.tar.gz &&  \
    mv aarch64-openeuler-linux-gnu openeuler_gcc_arm64le &&  \
    rm -rf aarch64-openeuler-linux-gnu.tar.gz
# deal x86_64 toolchain
RUN tar xzvf x86_64-openeuler-linux-gnu.tar.gz &&  \
    mv x86_64-openeuler-linux-gnu openeuler_gcc_x86_64 &&  \
    rm -rf x86_64-openeuler-linux-gnu.tar.gz
# deal arm toolchain
RUN tar xzvf arm-openeuler-linux-gnueabi.tar.gz &&  \
    mv arm-openeuler-linux-gnueabi openeuler_gcc_arm32le &&  \
    rm -rf arm-openeuler-linux-gnueabi.tar.gz
# deal riscv64 toolchain
RUN tar xzvf riscv64-openeuler-linux-gnu.tar.gz &&  \
    mv riscv64-openeuler-linux-gnu openeuler_gcc_riscv64 && \
    rm -rf riscv64-openeuler-linux-gnu.tar.gz
RUN rm -rf merge_data.sh
