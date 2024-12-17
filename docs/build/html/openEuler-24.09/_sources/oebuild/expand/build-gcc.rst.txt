.. _oebuild_expand_build_gcc:

构建gcc toolchain使用指导
#########################

本章节内容会介绍 oebuild 如何快速构建gcc交叉编译链的方法

.. note::

   在开始构建前，请确保构建主机满足以下条件：

   - 至少有 **50G** 以上的空闲磁盘空间，建议预留尽可能多的空间。
   - 至少有 **8G** 内存，建议使用内存、CPU数量更多的机器，增加构建速度。


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

成功创建工作目录后，**切换到工作目录** 执行以下命令，下载目标版本的项目源码：

* ``oebuild update yocto``

下载完成后，工作目录如下：

  .. code-block:: console

     $ tree -L 1 workdir_master/
     workdir_master/
     ├── oebuild.log
     └── src

  | ``oebuild.log``：oebuild 的操作日志。
  | ``src``：目标版本依赖的软件包源码目录，包括 yocto-meta-openeuler。

第 2 步: 创建定制化的构建配置文件
*********************************

**在 oebuild 工作目录下**，执行以下命令，创建定制化的构建配置文件：

* ``oebuild generate --gcc [--gcc_name gcc_names] [-d DIRECTORY]``

  * ``--gcc``：表示构建gcc交叉编译链。
  * ``--gcc_name <GCC NAME>``：表示gcc交叉编译链的类型，可以多选。
  * ``-d <DIRECTORY>``：构建目录，用于存放构建产物。
  * 当不输入任何参数时，会进入命令行菜单选择界面。

    .. code-block:: console

        oebuild generate

    具体界面如下图所示:

    .. image:: ../../_static/images/generate/oebuild-generate-select-gcc.png

  1. 此时在"choice build target"中选择"GCC TOOLCHAIN"表示构建GCC交叉编译链
  2. 在下面列出的交叉编译链类型中选择需要构建的类型
  3. 在directory输入编译目录名，至此按q，退出，按y确认即可生成编译目录

  或者直接在命令行输入命令
  
  .. code-block:: console

      # 例如：
      # 想要编译aarch64与arm的交叉编译链
      $ oebuild generate --gcc --gcc_name aarch64 --gcc_name arm -d gcc-aarch64-arm

  执行成功后，会在 oebuild 的工作目录下创建出 ``build`` 目录，如：

  .. code-block:: console

     $ tree build/
     build/
     └── gcc-aarch64-arm
         └── toolchain.yaml

  ``toolchain.yaml`` 即为交叉编译链在编译目录下的配置文件。

第 4 步：更新环境
******************

在构建交叉编译链中，是需要将交叉编译链所在目录的全部文件都拷贝到编译目录中的，因此执行以下命令进行拷贝操作

.. code-block:: console

  oebuild toolchain upenv

第 5 步：下载源码
*****************

这里是下载gcc交叉编译链所需要的相关代码，下载的源码会放在open_source目录下

.. code-block:: console

  oebuild toolchain downsource

第 6 步：执行构建
******************

在第2步生成配置文件中，我们有选定交叉编译链流程，在这一步中，我们可以直接执行自动构建，也可以直接构建某个交叉编译链，也可以进入编译环境进行实时交互

- 直接执行自动构建
  
  .. code::

    oebuild toolchain auto

- 直接构建某个交叉编译链，例如aarch64
  
  .. code::

    oebuild toolchain aarch64

- 进入编译环境，然后构建aarch64

  .. code::

    oebuild toolchain
    cp config_aarch64 .config
    ct-ng build

构建完成后，在编译目录下的x-tools存放着交叉编译链的产物
