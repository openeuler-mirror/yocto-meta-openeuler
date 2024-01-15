.. _prebuilt_tool:

预构建工具特性
********************

预构建工具介绍
####################

openEuler Embedded 的预构建工具借鉴了 Yocto 官方的 `buildtools <https://docs.yoctoproject.org/ref-manual/system-requirements.html#building-your-own-buildtools-tarball>`_ 方法，通过 nativesdk 方式，将 openeuler-image 构建所需的主机命令和部分依赖的 native 包预先构建并统一安装到 SDK 工具中，即预构建工具。在构建 image 时，这些 native 包无需再次构建，从而显著减少了构建时间。

在某种意义上，主机包等同于 native 包。举例来说，执行 ``bitbake meson-native`` 时，Yocto 会从上游下载 meson 源码，编译出 meson 二进制及其他产物。此 meson 二进制也可以替换为使用主机上的 meson 命令，从而避免去构建 meson-native 包。nativesdk-meson 在 meson-native 的基础上提供了打包功能，将构建出的产物打包成多个 rpm 子包，如 nativesdk-meson-version-xxx.rpm、nativesdk-meson-dev-version-XXX.rpm等。这样做的好处是，这些 rpm 包可以在其他匹配的环境中安装并使用，实现了单次构建的重复应用，大大降低了移植成本。

openEuler 开发者在 yocto-meta-openeuler 中进行了多项准备工作，以实现兼容预构建工具的构建方式。这些工作包括适配 autotools 类、配置 rpmdeps 以及使用 meson 工具等。社区开发者可以根据需求自行构建预构建工具，例如针对 arm64 架构的特定预构建工具。


预构建工具开发指南
#####################

预构建工具构建方式
----------------------

按照以下步骤构建预构建工具。

::

    $ oebuild generate -d prebuilt_tool
    $ cd build/prebuilt_tool
    $ oebuild bitbake
    $ vi conf/local.conf
    ### 修改 MACHINE 变量为 qemux86-64(x86环境构建)
    ### 注释 TCMODE = "external-toolchain" 配置
    ### 修改 OPENEULER_PREBUILT_TOOLS_ENABLE = "no"
    $ bitbake buildtools-extended-tarball

目前，oebuild 尚未实现自动配置预构建工具的配置文件。因此，需要按照上述步骤手动进行配置。

构建完成的预构建工具产物位于 :file:`tmp/deploy/sdk` 目录。

::

    $ ls ./tmp/deploy/sdk/
    x86_64-buildtools-extended-nativesdk-standalone-version.host.manifest  x86_64-buildtools-extended-nativesdk-standalone-version.target.manifest
    x86_64-buildtools-extended-nativesdk-standalone-version.sh             x86_64-buildtools-extended-nativesdk-standalone-version.testdata.json
    ### 运行 sh 脚本解压安装到指定目录
    $ sh ./tmp/deploy/sdk/x86_64-buildtools-extended-nativesdk-standalone-23.09.sh -y -d /path/to/install_sdk_dir
    $ ls /path/to/install_sdk_dir/
    environment-setup-x86_64-openeulersdk-linux  relocate_sdk.py  relocate_sdk.sh  sysroots  version-x86_64-openeulersdk-linux
    ### 运行 environment-setup-x86_64-xxx-linux 初始化 sdk 环境
    $ source /path/to/install_sdk_dir/environment-setup-x86_64-openeulersdk-linux

在环境初始化完成后，您应该使用 ``env`` 命令来验证环境变量的设置是否正确。一种有效的验证方法是检查环境变量 **PATH** 是否包含了预构建工具的二进制路径，以确保预构建工具能够正确运行。

预构建工具中添加包方式
-------------------------

示例：预构建工具中添加 make 命令。

修改 :file:`meta-openeuler/recipes-core/meta/buildtools-extended-tarball.bbappend` 文件，按照如下方式适配 **TOOLCHAIN_HOST_TASK** 变量：

.. code-block::

    TOOLCHAIN_HOST_TASK += "nativesdk-make"

接下来，请按照上述步骤构建，即可完成包含 ``make`` 命令的预构建工具构建。


Yocto 构建使用主机二进制命令指导
###################################

尽管主机环境中已经存在某个命令，Yocto 仍会尝试构建对应的 native 包。为了避免构建 native 包，我们需要适配 **ASSUME_PROVIDED** 变量；而为了使用主机中的二进制工具，我们需要适配 **HOSTTOOLS** 变量。

以下是这两个变量的简要介绍：

- ASSUME_PROVIDED：字面意思是“假定已提供”，其作用是防止将对应的包加入构建队列，即使有依赖关系也不会构建该包。
- HOSTTOOLS：表示使用环境中已存在的二进制命令。

以下是一个示例，展示了如何取消 bison-native 的编译，并使用环境中已有的 bison 命令：

.. code-block::

    ASSUME_PROVIDED += "bison-native"
    HOSTTOOLS += "bison"

在 openEuler 中，我们使用 :file:`meta-openeuler/conf/distro/include/openeuler_hosttools.inc` 文件来统一管理主机工具的构建和使用。


FAQ
###########

**Q:** 为什么不直接使用主机上的包替代 native 包？

**A:** 对于某些二进制程序，如 rpm 命令，Yocto 需要对其进行特定的修改或打补丁以满足构建要求。因此，预构建工具更适合 Yocto 构建使用，因为它能够更好地处理这些特定的需求。然而，对于一些简单的命令，开发者可以根据自己的需求选择使用主机环境中的命令或预构建工具中的命令。


**Q:** 为什么预构建工具不包含所有的 native 包？

**A:** 原因主要有以下几点：

- 一些包涉及到 Yocto 的底层配置，如 pseudo-native 和 python3-native，这些配置相当复杂，使得将这些包纳入预构建工具的难度较大；
- 部分包的配方（\*.bb）不支持 nativesdk 的构建方式。

即便这些包并未被纳入环境中，通过预构建工具，仍可以显著减少构建时间。
