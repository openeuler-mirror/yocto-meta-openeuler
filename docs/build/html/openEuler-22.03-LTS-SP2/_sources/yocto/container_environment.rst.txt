openEuler Embedded 容器环境介绍
###################################

相比较22.03版本，22.09版本执行构建前多了一个步骤：

.. code-block:: 

    $ source /opt/buildtools/nativesdk/environment-setup-x86_64-pokysdk-linux

此步骤会修改环境配置，生成一个适合 openeuler-image 构建的环境，可通过 env 命令对比执行前后的环境配置；此外，/opt/buildtools/nativesdk 的生成与 Yocto 密不可分，接下来介绍为什么需要这个步骤。

1. Yocto 构建对主机环境有要求
================================

为了 Yocto 能够正常的构建，主机上需要存在一些工具包，如 git，tar，python 等，Yocto 对这些工具的版本有一定的要求，如果主机环境并不满足要求，那么构建可能会报错。

2. 配置适合 Yocto 构建的主机环境
==================================

Yocto 官网指明了三种方式可以方便地配置主机环境：第一种是使用 poky 自带的 install-buildtools 脚本安装；第二种是从官网下载 buildtools 压缩文件，该压缩文件同时是一个 shell 脚本，执行脚本就可以安装 sdk 工具到指定的位置；第三种是开发者提前构建 buildtools 压缩文件。

参考：`yocto 官方文档1.3节 <https://docs.yoctoproject.org/current/ref-manual/system-requirements.html#required-git-tar-python-and-gcc-versions>`_

3. Yocto 构建方式
=====================

Yocto 针对一个包文件通常会有三种构建方式：target、native、nativesdk。

- **target** 即目标构建，一般以 bitbake package 实现，使用交叉编译工具链去编译包，如 x86 环境中构建 arm32 的包；
- **native** 即主机构建，一般以 bitbake package-native 实现，使用主机上的编译器来编译包，不会打包成 rpm 包或者其他类型包，如 x86 环境下构建 x86 的包；
- **nativesdk** 构建，一般以 bitbake nativesdk-package 实现，相比较 native 构建多了打包等步骤，将编译出的产物拆分到一个个包中供使用。

| 若 bb 文件中存在如下语句：
| **BBCLASSEXTEND = "native nativesdk"**：表示该包支持三种构建方式；
| **BBCLASSEXTEND = "native"**：表示支持 target 及 native 构建方式；
| **inherit native** or **inherit nativesdk**：表示该 bb 只是一个 native 或者 nativesdk 包，只支持一种构建方式。


4. 配置一个适合 openeuler-image 构建的环境
=============================================

openEuler Embedded 为了减少构建主机包的时间，将尽可能多的 native 包都配置到了环境中，这是为了做到构建时不去构建所依赖的 native 包，而是直接从环境中获取，这样可以大幅减少构建时间，配置环境参考第二节 buildtools 的构建方式。

openEuler Embedded buildtools 构建方法：

.. code-block:: 

    $ git clone -b nativesdk-3.3.6 https://gitee.com/openeuler/yocto-poky.git
    $ cd yocto-poky
    $ source oe-init-build-env
    $ bitbake buildtools-tarball or bitbake buildtools-extended-tarball

buildtools-tarball.bb、buildtools-extended-tarball.bb 文件存在于 **poky/meta/recipes-core/meta/** 目录， 原理是将 nativesdk 构建的包生成一个 sdk 工具（位于 **build/tmp/deploy/sdk** 目录），开发者可通过将 nativesdk 工具安装到指定目录或者移动到另一个相同的主机环境中安装使用，然后执行目录中的环境配置脚本配置环境，这时就配置好了相应的环境。

执行步骤：

a. 安装 nativesdk 工具

.. code-block::

    $ sh x86_64-buildtools-extended-nativesdk-standalone-3.3.6.sh -y -d /opt/buildtools/nativesdk

b. 初始化 openEuler Embedded 构建环境

.. code-block::

    $ source /opt/buildtools/nativesdk/environment-setup-x86_64-pokysdk-linux
