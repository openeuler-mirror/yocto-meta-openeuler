.. _yocto_add_package_recipe:

新增配方支持指导
###############################

配方（\*.bb 文件）是 Yocto 项目中的核心组成部分，每个软件组件的构建都依赖于相应的配方来进行定义和配置，Yocto 构建系统通过这些配方来管理软件组件的构建过程。从零开始编写一个配方文件可能会比较繁琐，尽管已经在 \*.conf 文件中配置好了绝大多数的变量。建议先学习 :ref:`yocto_recipe` 章节了解配方。

如果要为每个开源包都手动编写配方文件，将是一项非常耗时和复杂的工作。幸运的是，Yocto 的官方仓库已经为大部分软件包提供了指定版本的配方文件。

设想一种情况，如果您的源码版本与 Yocto 官方仓库中的配方版本相差不大，您可以考虑直接基于 Yocto 仓库中的配方进行少量修改，以实现切换源码的需求。这样可以节省大量时间和精力，并且确保构建过程的一致性和准确性。然而，请注意，直接修改官方仓库的配方文件可能不是最佳实践，因为它们可能会在未来的版本中更新或更改。

在可能的情况下，可以创建一个新的配方文件，并参考官方仓库中的现有配方作为基础，这是一种不错的方式。这种方式的缺点是会带来大量的冗余代码，同时不好跟进上游版本维护。Yocto 提供了一种机制，即 \*.bbappend 文件，bbappend 文件允许用户为现有的配方文件添加或覆盖变量和任务，而无需复制整个配方。这样既避免了冗余代码，又便于与上游版本维护保持同步。我们将在下文中详细介绍 bbappend 文件。


bbappend 文件介绍
=====================

bbappend 文件是 Yocto 构建系统中的一个特殊文件，用于扩展或修改现有的配方文件。它允许用户为现有的软件包添加额外的构建步骤、修改变量或添加依赖关系，而无需修改原始的配方文件。使用 bbappend 文件的优点在于，它可以轻松地对现有配方进行微调，而不会破坏原始的构建逻辑。这使得在构建过程中添加自定义构建步骤、修复兼容性问题或添加特定平台的支持变得简单。

命名规范上，bbappend 文件通常以 <package_name>_<package_version>.bbappend 的形式命名，其中 <package_name> 是要扩展的原始配方文件的名称。它的内容类似于一个普通的配方文件，但主要用于扩展而不是完全替换原始配方。

要使用 bbappend 文件，您需要将其放在 **BBFILES** 变量指定的目录中。构建系统会自动检测并应用这些文件，按照它们在目录中的顺序进行加载和应用。


bbappend 在 openEuler 嵌入式的应用实践
=========================================

配方文件查找
----------------------

bbappend 需要基于已知的配方文件，如果在已知的 :file:`poky/meta` 等层没有找到需要的配方文件，可以在 `OpenEmbedded Layer <http://layers.openembedded.org/layerindex/branch/master/recipes/>`_ 搜索，然后拷贝需要的文件（bb文件、补丁等）到 meta-openeuler 层。再根据需要添加 bbappend 文件。


切换 openEuler 源码
-----------------------

构建时，我们使用的源码主要来源是 `src-openEuler <https://gitee.com/organizations/src-openeuler/projects>`_  与 `openEuler <https://gitee.com/organizations/openeuler/projects>`_  。在切换源码时，需要考虑以下几种情形。

- **情形一：** 源码来源不一致。Poky 通常使用官方链接作为源码的来源，这有其明显的优势，但可能会受到国内网络速度的限制，导致源码获取速度较慢。

  面对情形一，openEuler 首先在默认的 ``do_fetch`` 任务中配置了 ``do_openeuler_fetch`` 子任务，用于获取自 openEuler 的源代码。 ``do_openeuler_fetch`` 任务会根据 :file:`.oebuild/manifest.yaml` 中软件包的 commit 信息，下载源码到本地路径（:file:`/usr/openeuler/src`），原理见 :ref:`openeuler_fetch` 。关于软件包源码的组织方式，详情参考 :ref:`add_package_src`。

  下一步需要在在配方中将 **SRC_URI** 指定的官方链接删除，并添加本地源码路径，详细步骤参考 :ref:`openeuler_src_uri_remove`。


- **情形二：** 源码版本不一致。由于选择源码来源自 openEuler，这可能会导致源码版本不一致，因为不同来源的版本维护可能存在差异。

  面对情形二，在处理源码版本不一致的问题时，openEuler 借助 bbappend 文件中的模糊匹配机制来有效地解决。通过这种方式，开发者能够根据不同的源码版本进行匹配，并在追加配方中重新配置相应的版本号。以 openEuler 例子 :file:`meta-openeuler/recipes-devtools/libcomps/libcomps_%.bbappend` 来说，openEuler 中 libcomps 源码的实际版本为 0.1.19，而 Poky 中 libcomps 配方的版本是 0.1.18, 但我们可以使用 :file:`libcomps_%.bbappend` 进行模糊匹配，并在追加配方中重新配置 **PV** 为匹配的版本号（如 0.1.19）。这种机制使得我们可以轻松地处理源码版本不一致的问题，确保构建过程的顺利进行。配置如下：

  ::
      
      ### libcomps_%.bbappend
      PV = "0.1.19"


- **情形三：** 解压源码后名称不一致。有些 tar 包在解压后，其文件和目录名称可能与预期不一致，这可能会给后续的构建过程带来困扰。

  面对情形三，解压源码后名称不一致。为了解决这个问题，我们需要重新配置变量 **S**，以确保构建时能够找到正确的解压后的源码目录。以 openEuler 例子 :file:`meta-openeuler/recipes-devtools/libcomps/libcomps_%.bbappend` 来说，poky 指定源码解压后得到的源码目录为 :file:`git`，但 openEuler 中 libcomps 源码压缩包解压后源码目录为 :file:`libcomps-${PV}` （也可以简写为${BP}），因此我们需要重新配置变量 **S**， 这样构建时才能找到解压后的源码目录。配置如下：

  ::
      
      ### libcomps_%.bbappend
      S = "${WORKDIR}/${BP}"


基于 openEuler 源码构建示例
===================================

**切换 libcomps 使用 openEuler 源码步骤如下：**

1. :file:`.oebuild/manifest.yaml` 增加如下行：

::

    libcomps:
    remote_url: https://gitee.com/src-openeuler/libcomps.git
    version: ba528fe723a61dbccc67f557b7566318c3e4193d

2. :file:`meta-openeuler/recipes-devtools/libcomps/libcomps_%.bbappend` 内容如下：

::

    ### 去除 SRC_URI 中 git 开头的链接
    OPENEULER_SRC_URI_REMOVE = "git"

    ### 重新设置 PV
    PV = "0.1.19"

    ### 替换源码为本地路径
    SRC_URI:prepend = "file://${PV}.tar.gz \
            "

    ### 重新设置源码目录
    S = "${WORKDIR}/${BP}"


3. 运行 bitbake 构建

::

    ...
    $ oebuild bitbake
    $ bitbake libcomps

在构建成功后，表示新增软件包配方的支持已完成，并且它现在可用于部署到镜像中。
