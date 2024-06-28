openEuler Embedded 开发容器环境介绍
###################################

openEuler Embedded 使用构建容器与 Yocto 工程进行开发，构建容器预先安装了交叉编译工具链和预构建工具，使用容器的主要优势在于其能够显著减少构建环境的差异性，确保一致性和可移植性。

交叉编译工具链集成了基础C库以及gcc、ld等关键构建工具，以满足交叉编译的需求；预构建工具是一款定制的SDK，旨在缩短镜像的构建时间，提高开发效率。

接下来，我们将逐步探讨为何引入预构建工具，以及它如何为开发流程带来效益。


**1. Yocto 构建对主机环境有要求**

为了 Yocto 能够正常的构建，主机上需要存在一些工具包，如 git，tar，python 等，Yocto 对这些工具的版本有一定的要求，如果主机环境并不满足要求，那么构建可能会报错。


**2. 配置适合 Yocto 构建的主机环境**

Yocto 官网指明了三种方式可以方便地配置主机环境：第一种是使用 poky 自带的 install-buildtools 脚本安装；第二种是从官网下载 buildtools 压缩文件，该压缩文件同时是一个 shell 脚本，执行脚本就可以安装 sdk 工具到指定的位置；第三种是开发者提前构建 buildtools 压缩文件。

参考：`yocto 官方文档1.3节 <https://docs.yoctoproject.org/current/ref-manual/system-requirements.html#required-git-tar-python-and-gcc-versions>`_


**3. 配置一个适合 openeuler-image 构建的环境**

对比 Yocto 原生工程，openEuler Embedded 将更多的包加入了 buildtools 中，这是为了在正式构建镜像时不去构建所依赖的 native 包，而是直接从 buildtools 中获取，这样可以大幅减少构建时间。我们将此 buildtools 称为预构建工具。

关于预构建工具的构建方法及更多细节，请参阅 :ref:`预构建工具特性 <prebuilt_tool>` 章节。

假设您已经获取了预构建工具文件，接下来介绍如何使用预构建工具：

a. 安装预构建工具

.. code-block::

    $ sh x86_64-buildtools-extended-nativesdk-standalone-version.sh -y -d /opt/buildtools/nativesdk


b. 初始化 openEuler Embedded 构建环境

.. code-block::

    $ source /opt/buildtools/nativesdk/environment-setup-x86_64-openeulersdk-linux
