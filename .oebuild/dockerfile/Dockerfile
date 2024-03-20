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

RUN mkdir -p /opt/buildtools/nativesdk/crosstool-ng

WORKDIR /opt/buildtools/nativesdk/crosstool-ng

RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2

RUN tar jxvf crosstool-ng-1.26.0.tar.bz2

RUN ./crosstool-ng-1.26.0/configure

RUN make

RUN sudo make install

RUN mkdir -p /opt/buildtools/nativesdk/sdk_info
# download nativesdk release
WORKDIR /opt/buildtools/nativesdk/sdk_info

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/x86_64-buildtools-extended-nativesdk-standalone-23.09.testdata.json

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/1_x86_64-buildtools-extended-nativesdk-standalone-23.09.sh

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/2_x86_64-buildtools-extended-nativesdk-standalone-23.09.sh

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/3_x86_64-buildtools-extended-nativesdk-standalone-23.09.sh

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/x86_64-buildtools-extended-nativesdk-standalone-23.09.target.manifest

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/x86_64-buildtools-extended-nativesdk-standalone-23.09.host.manifest

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/nativesdk-v0.1.0/merge_data.sh

RUN bash ./merge_data.sh

RUN ./x86_64-buildtools-extended-nativesdk-standalone-23.09.sh -d /opt/buildtools/nativesdk -y

RUN . /opt/buildtools/nativesdk/environment-setup-x86_64-openeulersdk-linux

RUN mkdir -p /usr1/openeuler/gcc
# download toolchain release
WORKDIR /usr1/openeuler/gcc

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/1_aarch64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/2_aarch64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/3_aarch64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/1_x86_64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/2_x86_64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/3_x86_64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/1_arm-openeuler-linux-gnueabi.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/2_arm-openeuler-linux-gnueabi.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/3_arm-openeuler-linux-gnueabi.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/1_riscv64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/2_riscv64-openeuler-linux-gnu.tar.gz

RUN wget https://gitee.com/openeuler/yocto-meta-openeuler/releases/download/toolchians-v0.1.0/merge_data.sh

RUN bash ./merge_data.sh

RUN tar xzvf aarch64-openeuler-linux-gnu.tar.gz &&  \
    mv aarch64-openeuler-linux-gnu openeuler_gcc_arm64le &&  \
    rm -rf aarch64-openeuler-linux-gnu.tar.gz

RUN tar xzvf x86_64-openeuler-linux-gnu.tar.gz &&  \
    mv x86_64-openeuler-linux-gnu openeuler_gcc_x86_64 &&  \
    rm -rf x86_64-openeuler-linux-gnu.tar.gz

RUN tar xzvf arm-openeuler-linux-gnueabi.tar.gz &&  \
    mv arm-openeuler-linux-gnueabi openeuler_gcc_arm32le &&  \
    rm -rf arm-openeuler-linux-gnueabi.tar.gz

RUN tar xzvf riscv64-openeuler-linux-gnu.tar.gz &&  \
    mv riscv64-openeuler-linux-gnu openeuler_gcc_riscv64 && \
    rm -rf riscv64-openeuler-linux-gnu.tar.gz

RUN rm -rf merge_data.sh

RUN pip install pyyaml pygit gitpython

RUN rm -rf /opt/buildtools/nativesdk/crosstool-ng

RUN rm -rf /opt/buildtools/nativesdk/sdk_info