.. _ascend_ffmpeg:

构建Ascend加速的FFmpeg使用指导
####################################

本章主要介绍如何在 openEuler Embedded 构建环境中，为 FFmpeg 6.1.1 增加 Ascend NPU 硬件加速能力（H.264/H.265 编解码），以及如何打包部署到 Orange Pi AI Pro 等带 Ascend NPU 的真机上进行验证。

.. note::

   在构建前，请确保构建主机满足以下条件：

   - 至少有 **8G** 内存（交叉编译 FFmpeg 较耗内存）。
   - 建议有 **100G** 以上存储（CANN 安装包、源码、构建产物合计较大）。
   - 已安装 Docker，并具备拉取构建镜像的网络条件。
   - 目标真机已安装 Ascend NPU 驱动与 CANN runtime（用于最终转码验证）。

简介
***********************************

FFmpeg 是一套开源的多媒体处理库与工具集，广泛用于音视频编解码、转码、流媒体处理。openEuler Embedded 默认携带 FFmpeg 6.1.1，但未启用 NPU 加速。

Ascend NPU（如 Orange Pi AI Pro 20T 搭载的 Atlas 200I A2 / Ascend 310B）通过 CANN（Compute Architecture for Neural Networks）的 DVPP/HiMpi 接口提供硬件视频编解码能力。华为针对 FFmpeg 4.4.2 提供了一套 ascend 补丁（``addfile``），新增了 ``h264_ascend`` / ``h265_ascend`` 编解码器与 ``ascend`` hwaccel。

由于 openEuler Embedded 使用 FFmpeg 6.1.1，编解码器结构（``AVCodec`` → ``FFCodec``）、AVFifo API、配置宏分离（``config_components.h``）等均有变化，不能直接使用 4.4.2 补丁。本文档对应的 ``ffmpeg-6.1.1-ascend.patch`` 已完成 4.4.2 → 6.1.1 的适配，可直接应用。

**特性概览：**

   - 新增 ``h264_ascend`` / ``h265_ascend`` 编码器与解码器
   - 新增 ``ascend`` 硬件加速方法（``-hwaccel ascend``）
   - 通过 CANN stub 库完成离线链接，运行时由真机 CANN runtime 提供真实实现

**预编译 RPM（可直接下载使用）**

如果不想自行编译，可直接下载已构建好的预编译 RPM 包，跳过第 1~5 步，按 ``第 6 步：真机部署与运行验证`` 进行安装与验证：

   - 下载地址：https://ug.link/oee-nas-server/filemgr/share-download/?id=07f089745f7e4e60b5e96080bd9a9dd1

下载得到 ``ffmpeg-ascend-6.1.1-1.ascend.aarch64.rpm``，安装到 ``/usr/local/ffmpeg-ascend``，含 ``/usr/bin/ffmpeg-ascend`` 自动探测 CANN 路径的 wrapper。真机需先就绪 CANN runtime（提供 ``libacl_dvpp_mpi.so`` / ``libascendcl.so``）。

资源准备
***********************************

构建需要三类资源：FFmpeg 源码、ascend 补丁、CANN toolkit。

1. FFmpeg 源码
========================================

FFmpeg 源码信息以 ``yocto-meta-openeuler`` 仓库的 ``.oebuild/manifest.yaml`` 为准：

.. code-block:: yaml

   ffmpeg:
     remote_url: https://atomgit.com/src-openeuler/ffmpeg.git
     version: f8154f398b1e593446792f5dfd091f57e4789de6

获取方式：

.. code-block:: shell

   $ git clone https://atomgit.com/src-openeuler/ffmpeg.git
   $ cd ffmpeg
   $ git checkout f8154f398b1e593446792f5dfd091f57e4789de6

该仓库内含上游 ``ffmpeg-6.1.1.tar.xz`` 源码包与 openEuler 打包所用的 ``ffmpeg.spec``。

2. ascend 补丁
========================================

已适配 6.1.1 的补丁从以下链接获取（包含 6 个新增文件与 8 个现有文件修改）：

   - https://ug.link/oee-nas-server/filemgr/share-download/?id=4c311b2ab3084cf594c267fb1f56d3ab

下载后得到 ``ffmpeg-6.1.1-ascend.patch``。

3. CANN toolkit
========================================

CANN 7.0.0 toolkit 用于链接（实际转码依赖真机上的 CANN runtime）。下载地址：

   - https://ug.link/oee-nas-server/filemgr/share-download/?id=a63fe76f6be741aa9e96774d575439de

下载后得到 ``Ascend-cann-toolkit_7.0.0_linux-aarch64.run``。

.. note::

   CANN toolkit 安装器对 python 版本与运行环境有要求，且其真实库（``libacl_dvpp_mpi.so``）会传递依赖 NPU 驱动符号，无法在无 NPU 的构建主机上直接链接。因此本文档**不运行完整安装器**，而是从中**提取 stub 库**用于离线链接（见后文）。

第 1 步：准备构建环境
***********************************

构建在一个基于 Docker 的 aarch64 模拟环境内进行（x86 宿主 + qemu 用户态模拟）。推荐使用 openEuler Embedded 提供的 ``openeuler-ibrobot-dev`` 镜像。

1. 拉取镜像并以守护态启动容器
========================================

.. code-block:: shell

   $ IMAGE=swr.cn-north-4.myhuaweicloud.com/openeuler-embedded-2/openeuler-ibrobot-dev:latest
   $ docker pull $IMAGE
   $ docker run -d --name ascend-build \
       -v <work_dir>:/root/openeuler_rootfs/work \
       --entrypoint /bin/bash $IMAGE -c 'sleep infinity'

其中 ``<work_dir>`` 是主机上的工作目录，需放置源码、补丁、CANN 安装包。

.. note::

   - 容器入口脚本会自动 ``chroot`` 进入 ``/root/openeuler_rootfs``（aarch64 rootfs），依赖宿主 ``binfmt_misc`` + ``qemu-aarch64-static`` 运行 aarch64 二进制。
   - 因此挂载点必须落在 ``/root/openeuler_rootfs`` 之下（如上例的 ``/root/openeuler_rootfs/work``），chroot 内才能看到挂载内容。

2. 在 chroot 内执行命令
========================================

容器内不能直接 ``docker run -it xxx bash`` 进入，应使用以下形式在 aarch64 rootfs 中执行命令：

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c '<command>'

注意 rootfs 内 shell 为 ``/bin/bash.bash``。下文为简洁，统一用 ``chroot-run`` 代指该执行形式。

3. 验证 chroot 环境
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c 'uname -m; gcc --version | head -1'

期望输出 ``aarch64`` 与 gcc 12.x。chroot 内已具备 gcc、make、automake、autoconf、libtool、pkg-config、patch、python3 等构建工具。

第 2 步：提取 CANN runtime（stub 库）
*************************************

CANN 安装器无法直接跑，需要手动提取出 ``include`` 头文件与 ``lib64/stub`` 链接库。

1. 准备 CANN 安装包
========================================

将 ``Ascend-cann-toolkit_7.0.0_linux-aarch64.run`` 放入工作目录（chroot 内路径为 ``/work``）：

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'chmod +x /work/Ascend-cann-toolkit_7.0.0_linux-aarch64.run'

2. 修复 /var/log 符号链接
========================================

rootfs 中 ``/var/log`` 是指向 ``volatile/log`` 的符号链接，目标目录不存在会导致提取脚本失败：

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'mkdir -p /var/volatile/log'

3. 第一层提取
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work && ./Ascend-cann-toolkit_7.0.0_linux-aarch64.run --extract=/work/cann_extract'

4. 第二层提取（CANN-runtime）
========================================

第一层产物中包含若干内层 ``.run`` 包，其中 ``CANN-runtime`` 含我们需要的 ACL 头文件与 stub 库：

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work/cann_extract && ls *.run'
   # 找到类似 Ascend-cann-runtime_7.0.0_linux-aarch64.run 的包

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work/cann_extract && ./Ascend-cann-runtime_7.0.0_linux-aarch64.run --extract=/work/rt_extract'

5. 确认产物
========================================

提取后关键路径如下：

.. code-block:: text

   /work/rt_extract/runtime/
   ├── include/
   │   └── acl/
   │       ├── acl.h
   │       ├── acl/ops/acl_dvpp.h
   │       └── acl/dvpp/hi_*.h        # hi_mpi_* 接口头文件
   └── lib64/
       └── stub/
           └── aarch64/
               ├── libacl_dvpp_mpi.so  # DVPP stub（仅导出 hi_mpi_* 符号）
               └── libascendcl.so      # AscendCL stub

这些 stub 库仅依赖系统库、不含 NPU 驱动符号，专用于离线/交叉链接；真实实现由真机上的 CANN runtime 提供。

.. note::

   一定要使用 ``lib64/stub/aarch64`` 下的 stub 库，而**不是** ``lib64`` 顶层真实库。真实库会传递依赖 ``libruntime.so`` → ``drv_*/hal_*`` 等 NPU 驱动符号，在无驱动的构建主机上链接会失败。

第 3 步：应用补丁
***********************************

1. 解压 FFmpeg 源码
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work && tar xf /work/ffmpeg/ffmpeg-6.1.1.tar.xz'

得到 ``/work/ffmpeg-6.1.1/`` 源码树。

2. 应用 ascend 补丁
========================================

将下载的补丁放入工作目录后应用：

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work/ffmpeg-6.1.1 && patch -p1 < /work/ffmpeg-6.1.1-ascend.patch'

预期输出 14 个 ``patching file ...``，无 ``FAILED``。补丁涵盖：

   - **新增 6 个文件**：``libavcodec/ascend_enc.{c,h}``、``libavcodec/ascend_dec.{c,h}``、``libavutil/hwcontext_ascend.{c,h}``
   - **修改 8 个现有文件**：``libavutil/{pixfmt.h, pixdesc.c, hwcontext.h, hwcontext_internal.h, hwcontext.c, Makefile}``、``libavcodec/{allcodecs.c, Makefile}``

第 4 步：配置与编译
***********************************

1. 配置
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work/ffmpeg-6.1.1 && \
        export LD_LIBRARY_PATH=/work/rt_extract/runtime/lib64/stub/aarch64:$LD_LIBRARY_PATH && \
        ./configure \
          --prefix=/usr/local/ffmpeg-ascend \
          --enable-shared \
          --extra-cflags="-I/work/rt_extract/runtime/include" \
          --extra-ldflags="-L/work/rt_extract/runtime/lib64/stub/aarch64" \
          --extra-libs="-lacl_dvpp_mpi -lascendcl" \
          --enable-decoder=h264_ascend \
          --enable-decoder=h265_ascend \
          --enable-encoder=h264_ascend \
          --enable-encoder=h265_ascend'

.. note::

   - **不修改 ``configure`` 脚本**。ascend 编解码器通过 ``allcodecs.c`` 中的 ``extern const FFCodec`` 声明被自动探测，``configure`` 据此生成 ``CONFIG_H264_ASCEND_*`` 宏，使用标准 ``--enable-decoder/encoder`` 即可启用。
   - 安装前缀用 ``/usr/local/ffmpeg-ascend``，避免覆盖系统 ``/usr`` 下的 FFmpeg 6.1.1。

2. 编译与安装
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'cd /work/ffmpeg-6.1.1 && \
        export LD_LIBRARY_PATH=/work/rt_extract/runtime/lib64/stub/aarch64:$LD_LIBRARY_PATH && \
        make -j$(nproc) && make install'

由于 chroot 走 qemu 模拟，完整编译耗时较长（约 15~30 分钟，取决于宿主性能）。

3. 验证构建产物
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'export LD_LIBRARY_PATH=/usr/local/ffmpeg-ascend/lib:/work/rt_extract/runtime/lib64/stub/aarch64:$LD_LIBRARY_PATH && \
        /usr/local/ffmpeg-ascend/bin/ffmpeg -hwaccels 2>/dev/null | grep ascend && \
        /usr/local/ffmpeg-ascend/bin/ffmpeg -hide_banner -encoders 2>/dev/null | grep ascend && \
        /usr/local/ffmpeg-ascend/bin/ffmpeg -hide_banner -decoders 2>/dev/null | grep ascend'

期望输出：

.. code-block:: text

   ascend
    V..... h264_ascend          Ascend HiMpi H264 encoder (codec h264)
    V..... h265_ascend          Ascend HiMpi H265 encoder (codec hevc)
    V..... h264_ascend          Ascend HiMpi H264 decoder (codec h264)
    V..... h265_ascend          Ascend HiMpi H265 decoder (codec hevc)

.. note::

   运行时必须将 stub 库目录加入 ``LD_LIBRARY_PATH``，否则 ``libavcodec.so`` 因找不到 ``libacl_dvpp_mpi.so`` 无法加载。真机上替换为真实 CANN 库路径即可。

第 5 步：打包为 RPM（可选）
***********************************

为便于部署到真机，可基于构建产物打一个 aarch64 RPM。

1. 准备 staging 树
========================================

.. code-block:: shell

   $ docker exec ascend-build /usr/sbin/chroot /root/openeuler_rootfs /bin/bash.bash -c \
       'mkdir -p /work/staging/usr/local && \
        cp -a /usr/local/ffmpeg-ascend /work/staging/usr/local/ && \
        cd /work/staging && tar czf /work/staging.tar.gz .'

2. 在宿主层用 rpmbuild 打包
========================================

chroot 内无 ``rpmbuild``，需在宿主层（x86）打包。准备精简 spec：

.. code-block:: text

   Name:           ffmpeg-ascend
   Version:        6.1.1
   Release:        1.ascend%{?dist}
   Summary:        FFmpeg 6.1.1 with Ascend NPU hardware acceleration
   License:        LGPLv2.1+
   Source0:        %{name}-%{version}-staging.tar.gz

   # 禁用 strip（x86 strip 无法处理 aarch64 ELF）
   %global __strip /bin/true
   %global __objdump /bin/true
   # CANN 库由真机提供，不写入自动 Requires
   %global __requires_exclude ^libacl_dvpp_mpi\\.so.*|^libascendcl\\.so.*

   %description
   FFmpeg with Ascend hardware-accelerated H.264/H.265 encoders/decoders.

   %prep
   %build

   %install
   rm -rf %{buildroot}
   mkdir -p %{buildroot}
   tar xzf %{SOURCE0} -C %{buildroot}
   mkdir -p %{buildroot}%{_sysconfdir}/ld.so.conf.d
   echo "/usr/local/ffmpeg-ascend/lib" > %{buildroot}%{_sysconfdir}/ld.so.conf.d/ffmpeg-ascend.conf
   mkdir -p %{buildroot}%{_bindir}
   cat > %{buildroot}%{_bindir}/ffmpeg-ascend <<'EOF'
   #!/bin/bash
   FFMPEG_LIB=/usr/local/ffmpeg-ascend/lib
   for p in /usr/local/Ascend/ascend-toolkit/latest/aarch64/lib64 \
            /usr/local/Ascend/driver/lib64; do
       [ -d "$p" ] && EXTRA="$EXTRA:$p"
   done
   export LD_LIBRARY_PATH="$FFMPEG_LIB$EXTRA${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
   exec /usr/local/ffmpeg-ascend/bin/ffmpeg "$@"
   EOF
   chmod 0755 %{buildroot}%{_bindir}/ffmpeg-ascend

   %post -p /sbin/ldconfig
   %postun -p /sbin/ldconfig

   %files
   %dir /usr/local/ffmpeg-ascend
   /usr/local/ffmpeg-ascend/bin
   /usr/local/ffmpeg-ascend/lib
   /usr/local/ffmpeg-ascend/include
   /usr/local/ffmpeg-ascend/share
   %config(noreplace) %{_sysconfdir}/ld.so.conf.d/ffmpeg-ascend.conf
   %{_bindir}/ffmpeg-ascend

.. code-block:: shell

   $ mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS}
   $ cp <work_dir>/staging.tar.gz ~/rpmbuild/SOURCES/ffmpeg-ascend-6.1.1-staging.tar.gz
   $ cp ffmpeg-ascend.spec ~/rpmbuild/SPECS/
   $ rpmbuild --target aarch64 -bb ~/rpmbuild/SPECS/ffmpeg-ascend.spec

产物为 ``~/rpmbuild/RPMS/aarch64/ffmpeg-ascend-6.1.1-1.ascend.aarch64.rpm``。spec 通过 ``--target aarch64`` 设定包架构（不要在 spec 内硬编码 ``BuildArch``，否则会触发宿主架构兼容性检查失败）。

第 6 步：真机部署与运行验证
***********************************

1. 安装 RPM
========================================

将 RPM 传到真机后安装：

.. code-block:: shell

   # rpm -ivh ffmpeg-ascend-6.1.1-1.ascend.aarch64.rpm

若提示缺少 ``libSDL2`` / ``libxcb``（ffplay/avdevice 依赖，与转码验证无关），加 ``--nodeps`` 即可。

2. 验证编解码器注册
========================================

.. code-block:: shell

   $ ffmpeg-ascend -hwaccels | grep ascend
   $ ffmpeg-ascend -encoders | grep ascend
   $ ffmpeg-ascend -decoders | grep ascend

wrapper ``/usr/bin/ffmpeg-ascend`` 会自动探测 CANN runtime 库路径（``/usr/local/Ascend/ascend-toolkit/latest/aarch64/lib64`` 等）并设置 ``LD_LIBRARY_PATH``，无需手动配置。

3. 转码验证
========================================

.. code-block:: shell

   $ ffmpeg-ascend -hwaccel ascend -i input.mp4 -c:v h264_ascend output.h264

若 CANN runtime 装在非默认路径，需手动 ``export LD_LIBRARY_PATH`` 指向真实库目录后再运行。

注意事项
***********************************

#. **stub 库与真实库的区别**

   - 构建链接用 stub 库（``lib64/stub/aarch64``），仅含符号声明，无真实实现。
   - 真机运行用真实 CANN runtime 库（``lib64`` 顶层或驱动目录），含 NPU 调用实现。
   - 仅用 stub 运行时，``ffmpeg -encoders`` 能列出 ascend 编解码器，但实际转码会失败（stub 是空实现）。

#. **与系统 FFmpeg 共存**

   ascend 版本装在 ``/usr/local/ffmpeg-ascend``，不覆盖 ``/usr`` 下的系统 FFmpeg 6.1.1。通过 ``/etc/ld.so.conf.d/ffmpeg-ascend.conf`` 与 wrapper ``ffmpeg-ascend`` 隔离调用。

#. **补丁不含 configure 改动**

   补丁不修改 ``configure`` 脚本，编解码器通过 ``allcodecs.c`` 自动探测。启用方式为标准 ``--enable-decoder/encoder=h264_ascend``，无需 ``--enable-ascend``。

#. **关于 AVC/HEVC 补丁与 CVE 补丁**

   ``atomgit.com/src-openeuler/ffmpeg`` 仓库还含若干 CVE 修复补丁。本文 ascend 补丁基于**纯净 6.1.1** 生成，若需同时应用 CVE 补丁，建议先应用 CVE 补丁再应用 ascend 补丁，遇冲突时手动处理。

参考链接
***********************************

#. FFmpeg 官方网站: https://ffmpeg.org/
#. openEuler Embedded 在线文档: https://embedded.pages.openeuler.org/
#. CANN 商用版文档: https://www.hiascend.com/document/detail/zh/canncommercial/
#. Orange Pi AI Pro 用户手册（Ascend FFmpeg 章节）: 参见随设备文档
#. ffmpeg 源码仓库（manifest 锁定版本）: https://atomgit.com/src-openeuler/ffmpeg.git
