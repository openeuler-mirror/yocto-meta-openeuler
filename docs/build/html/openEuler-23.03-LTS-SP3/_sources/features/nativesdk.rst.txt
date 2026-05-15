nativesdk 特性
**********************

nativesdk 介绍
####################

openEuler Embedded nativesdk 工具参考 Yocto 官方提供的 `buildtools <https://docs.yoctoproject.org/ref-manual/system-requirements.html#building-your-own-buildtools-tarball>`_ 的实现方式，将 openeuler-image 构建所需要的主机包以及依赖的部分 xxx-native 包通过 nativesdk-xxx 的方式构建了出来，并安装到 buildtools（nativesdk）中，以减少构建时间。

某种意义上来说，xxx-native 包即主机包，如执行 bitbake meson-native 时 Yocto 会下载上游源码编译出一个 meson 二进制和其他的文件等，而 nativesdk-meson 在 meson-native 的基础上提供了打包功能，将构建出来的文件打包成多个 rpm 包，如 nativesdk-meson-XXX.rpm, nativesdk-meson-dev-XXX.rpm 等，这样做的一个好处是可以共享，移动到另一个匹配的环境中也能使用，可用于避免重复构建 xxx-native 包，节省构建时间。

理论上所有的 native 包都可以部署到环境，但是有些包涉及到 Yocto 的底层配置（如pseudo-native），也有一些包不支持 nativesdk 构建，即便这些包没有加入到环境中，也可以减少大量的构建时间。

.. note::

    开发者可以在环境中直接安装编译所需要的包。举例说明，nativesdk-meson 与 meson 包功能是类似的，开发者可以直接通过包管理器或者其他方式安装 meson 包，但 nativesdk 包有个很大的优势，因为它是 Yocto 构建出来的，所以它的使用可以兼容 Yocto 构建，而通过一般的包管理器直接安装的包则不一定具备。


开发指南
###################

openEuler 开发者在 nativesdk 工具兼容 yocto-meta-openeuler 上做了很多准备工作，如 autotools 类的适配，rpmdeps 的配置，meson 工具的使用等。openEuler Embedded nativesdk 的代码位于 `yocto-poky/nativesdk分支 <https://gitee.com/openeuler/yocto-poky/tree/nativesdk-3.3.6/>`_ 上，社区开发者可根据需要自行构建 nativesdk 工具，如构建一个在 arm64 架构下使用的 nativesdk 工具。

示例：如何让 openeuler-image 构建使用 nativesdk 中的 bison 包。

**步骤1**

  修改 yocto-poky/meta/recipes-core/meta/buildtools-extended-tarball.bb 文件，在 nativesdk 中加入 bison 包：

  .. code-block::

      TOOLCHAIN_HOST_TASK += "nativesdk-bison"

  接下来按照官方 `buildtools <https://docs.yoctoproject.org/ref-manual/system-requirements.html#building-your-own-buildtools-tarball>`_ 指导构建使用即可。

  .. note::

      如果你没有把 nativesdk 工具安装在 /opt/buildtools/nativesdk/ 目录，则需要在构建时将 OPENEULER_NATIVESDK_SYSROOT 字节更改为你所安装 nativesdk 工具的目录（参考 conf/local.conf 写法）。

**步骤2**

  尽管环境中已经存在了 bison 包，但是 Yocto 还是会去构建 bison-native 包，为了不再构建，需修改 meta-openeuler/conf/distro/include/openeuler_hosttools.inc 中 ASSUME_PROVIDED 与 HOSTTOOLS 变量，取消 bison-native 编译，使用环境中 bison 命令：

  .. code-block::

      ASSUME_PROVIDED += "bison-native"
      HOSTTOOLS += "bison"

  .. note::

      | ASSUME_PROVIDED: 该字节字面意思是“假定提供”，作用是将对应的包不加入构建队列，即使依赖也不会构建该包；
      | HOSTTOOLS: 该字节表示使用环境中的二进制命令。

存在的问题
##################

目前来说，nativesdk 的使用有一些不完善之处，构建 nativesdk 时采用的包源码直接来自于上游而非 openEuler，这一点开发者正在进行改进。
