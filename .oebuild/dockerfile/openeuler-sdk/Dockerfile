# base image
FROM openeuler/openeuler:21.09

RUN sed -i 's/repo.openeuler.org/archives.openeuler\.openatom\.cn/g' /etc/yum.repos.d/openEuler.repo

# yum install
RUN set -eux; \
yum -y install git java tar binutils-devel gperf sqlite-devel libffi-devel xz-devel \
zlib zlib-devel openssl-devel bzip2-devel ncurses-devel readline-devel \
libpcap-devel parted autoconf-archive chrpath gcc-c++ patch rpm-build flex \
autoconf automake m4 bison bc libtool gettext-devel createrepo_c net-tools \
wget sudo hostname rpcgen texinfo meson dosfstools mtools libmpc-devel \
gmp-devel ninja-build numactl-devel make python python3 python3-pip screen \
iproute help2man gdisk libstdc++-static diffstat lzip python3-devel rsync \
xz-lzma-compat xz unzip gcc g++ vim hwdata libxslt perl-XML-Parser umoci skopeo

ARG user=openeuler
ARG group=openeuler
ARG uid=1000
ARG gid=1000

# add build user
RUN groupadd -g ${gid} ${group} && useradd -c "${user}" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# modify /usr1 owner
RUN mkdir -p /usr1 && chown -R ${user}:${group} /usr1 /opt && chmod -R 755 /usr1 /opt

# modify default configs
RUN sed -i 's/TMOUT=300/TMOUT=/g' /etc/bashrc

# download ct-ng
WORKDIR /home/${user}
RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2
RUN tar jxvf crosstool-ng-1.26.0.tar.bz2
WORKDIR /home/${user}/crosstool-ng-1.26.0
RUN ./configure
RUN make
RUN sudo make install
WORKDIR /home/${user}
RUN rm -rf crosstool-ng-1.26.0 crosstool-ng-1.26.0.tar.bz2

USER ${user}

# install cmake=3.20.2 for llvm toolchain build
RUN pip install cmake==3.20.2 -i https://pypi.tuna.tsinghua.edu.cn/simple
