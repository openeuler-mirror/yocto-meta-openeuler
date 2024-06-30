.. _oebuild_usage:

构建OS镜像使用指导
##################

本章节内容会介绍 oebuild 的具体使用方法，可根据下述步骤，了解 oebuild 的相关命令并掌握如何构建定制化的 openEuler Embedded 镜像。

.. note::

   在开始构建前，请确保构建主机满足以下条件：

   - 至少有 **50G** 以上的空闲磁盘空间，建议预留尽可能多的空间，有助于运行多个镜像构建，通过重复构建提升效率。
   - 至少有 **8G** 内存，建议使用内存、CPU数量更多的机器，增加构建速度。

____

第 1 步: 初始化工作目录
************************

oebuild 的工作目录与 openEuler Embedded 版本是相关联的，构建不同版本的 openEuler Embedded，需要创建相对应的工作目录。
因此，推荐以openEuler Embedded版本号命名工作目录，例如 `workdir_master`。当前，可以通过执行以下命令，创建工作目录：

* ``oebuild init [-u URL] [-b BRANCH] [DIRECTORY]``

  * ``-u <URL>``：yocot-meta-openeuler 仓库地址，默认为 `yocto-meta-openeuler <https://gitee.com/openeuler/yocto-meta-openeuler>`_。
  * ``-b <BRANCH>``：yocot-meta-openeuler 版本分支，默认为 `master <https://gitee.com/openeuler/yocto-meta-openeuler/tree/master>`_。
    如需构建其它版本，直接使用该参数指定对应分支，例如：`-b openEuler-22.03-LTS-SP2`。
  * ``<DIRECTORY>``：需要创建的工作目录。注意，要确保当前用户拥有当前目录的读写权限，否则会报错：`Permission denied`；且不能指定当前目录中已有的目录，否则会报错：`mkdir <directory> failed`。

  .. code-block:: console

      # 例如：
      # 初始化 master 版本的工作目录
      $ oebuild init workdir_master

      # 初始化 openEuler-22.03-LTS-SP2 版本的工作目录
      $ oebuild init -b openEuler-22.03-LTS-SP2 workdir_2203-sp2

成功创建工作目录后，**切换到工作目录** 执行以下命令，下载目标版本的项目源码及构建容器：

* ``oebuild update``

下载完成后，工作目录如下：

  .. code-block:: console

     $ tree -L 1 workdir_master/
     workdir_master/
     ├── oebuild.log
     └── src

  | ``oebuild.log``：oebuild 的操作日志。
  | ``src``：目标版本依赖的软件包源码目录，包括 yocto-meta-openeuler、yocto-poky等。后续构建所依赖的软件包也会自动下载到该目录，包括 kernel、busybox、systemd等等。

____

第 2 步: 创建定制化的构建配置文件
*********************************

当前，openEuler Embedded 支持多种南向架构，包括 ARM/ARM64、X86_64、RISCV。在此基础上，oebuild 抽象封装了 openEuler Embedded 的大颗粒特性，
包括：混合部署(MICA)、图形、ROS、初始化服务(busybox or systemd)。用户可以通过 oebuild 自由组合所需特性，定制化 openEuler Embedded 版本。

**在 oebuild 工作目录下**，执行以下命令，创建定制化的构建配置文件：

* ``oebuild generate -p PLATFORM [-f FEATURES] [-d DIRECTORY]``

  * ``-p <PLATFORM>``：选择需要构建的目标机器类型。
  * ``-f <FEATURES>``：选择需要打开的特性，可多次指定 -f 打开多个特性。
  * ``-d <DIRECTORY>``：构建目录，用于存放构建产物，同一构建目录支持多次重复构建。
  * 当不输入任何参数时，会进入命令行菜单选择界面。

    .. code-block:: console

        oebuild generate

    具体界面如下图所示:

    .. image:: ../../../_static/images/generate/oebuild-generate-select.png
    
  1. 此时在"choice build target"中选择OS表示构建OS镜像，
  2. 在"choice platform"选择需要构建的单板，图中示例为qemu-aarch64
  3. 在"os features"下选择需要构建的特性
  4. 在directory输入编译目录名，至此按q，退出，按y确认即可生成编译目录

  或者直接在命令行输入命令

  .. code-block:: console

      # 例如：
      # 创建支持混合部署和systemd的 qemu-aarch64 镜像构建配置文件，构建目录为 build_arm64-mcs-systemd：
      $ oebuild generate -p qemu-aarch64 -f openeuler-mcs -f systemd -d build_arm64-mcs-systemd

      # 创建支持软实时和systemd的 x86-64 镜像构建配置文件，构建目录为 build_x86-rt-systemd：
      $ oebuild generate -p x86-64 -f openeuler-rt -f systemd -d build_x86-rt-systemd

  .. note::

     可以通过执行 ``oebuild generate -l`` 查看支持的南向列表和特性列表。南向支持的帮助文档请参阅 :ref:`南向支持章节 <bsp>`。
     特性文档请参阅 :ref:`关键特性章节 <openeuler_embedded_features>`。

执行成功后，会在 oebuild 的工作目录下创建出 ``build`` 目录，该目录包含多个用户定制的镜像构建目录，如：

  .. code-block:: console

     $ tree build/
     build/
     ├── build_arm64-mcs-systemd
     │   └── compile.yaml
     └── build_x86-rt-systemd
         └── compile.yaml

不同目录下的 ``compile.yaml`` 为对应的构建配置文件。

.. note::

   - | 在具体的镜像构建目录 ``<DIRECTORY>`` 下，可以重复触发构建，包括单个软件包的构建和镜像构建。

   - 针对单个构建目录 ``<DIRECTORY>``，支持重复使用 ``oebuild generate -d <DIRECTORY>`` 创建新的配置文件，以复用构建缓存加速构建，但需要注意：

     - | 一个目录对应一个 ``PLATFORM``，即上一次使用 ``-p x86-64 -d build_dir`` 创建出来的构建目录 build_dir，重新使用 ``-p qemu-aarch64 -d build_dir``，也无法复用上一次的构建缓存。

     - | 新增特性后，需要删除构建目录 ``<DIRECTORY>`` 下的 ``conf`` 文件夹再进行构建。因为当 conf 存在时，不会再根据 oebuild 创建的 compile.yaml 重新生成 conf，新增特性无法生效。
       | 例如，上一次使用 ``-f systemd -d build_dir`` 在 build_dir 下创建了配置文件并完成了构建，希望重新使用 ``-f busybox -d build_dir`` 变更特性，需要同步删除 build_dir 下的 conf 文件夹，才能构建 busybox 镜像。

____

第 3 步: 构建 openEuler Embedded
********************************

**在** ``compile.yaml`` **的同级目录** （即第二步创建出来的构建目录）下，执行以下命令，开始构建：

.. code-block:: console

    # 进入构建容器
    $ oebuild bitbake

    8<-------- 进入容器环境 --------

    # 构建 openEuler Embedded 镜像
    $ bitbake openeuler-image

    $ 构建 openEuler Embedded 的 SDK
    $ bitbake openeuler-image -c do_populate_sdk

    # 构建完成后，退出容器环境
    $ exit

    8<-------- 返回构建主机 --------

    # 在 output 目录中可以找到构建镜像
    $ cd output/<构建时间戳>

.. seealso::

   进入容器后，bitbake 的使用方法与 yocto 保持一致，一些常用命令如下：

   - ``bitbake <target> -c cleansstate``：清理 <target> 的构建缓存，一般在重新构建 <target> 之前执行，以防止缓存影响新增的修改。

   - ``bitbake <target> -e > env.log``：输出关于 <target> 相关的构建环境变量到 env.log 中，一般用于帮助开发人员编写 <target> 的构建配方。

   - ``bitbake <target> -g``：输出 <target> 相关的构建依赖分析 pn-buildlist、task-depends.dot。

   关于 bitbake 命令更详细丰富的用法，请参考 `yocto bitbake manual <https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-intro.html#the-bitbake-command>`_。

进一步了解
**********

经过上述步骤，您已了解如何使用 oebuild 创建定制化的 openEuler Embedded 镜像配置，以及如何构建 openEuler Embedded 版本。推荐您继续阅读以下章节内容：

- | :ref:`如何使用 openEuler Embedded SDK 进行开发 <install-openeuler-embedded-sdk>`：
  | 了解 openEuler Embedded SDK 的使用方法，如何用 SDK 快速构建内核模块和用户态程序。

- | :ref:`openEuler Embedded 南向支持 <bsp>`：
  | 了解 openEuler Embedded 如何在不同的硬件平台上部署。

- | :ref:`openEuler Embedded 关键特性 <openeuler_embedded_features>`：
  | 了解openEuler Embedded 正在进行的一些技术探索，参与社区的大颗粒特性。

- | :ref:`oebuild 命令手册 <oebuild_command>`：
  | 了解 oebuild 的其它功能，包括如何使用自定义的软件包版本基线（manifest）、自定义的构建工具链构建 openEuler Embedded。
