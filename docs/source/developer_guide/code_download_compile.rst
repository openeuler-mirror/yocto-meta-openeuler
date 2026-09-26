.. _code_download_compile:

下载编译指导
######################################

本章介绍 openEuler Embedded 源码的获取与镜像编译方法。详细的操作步骤请参阅 :ref:`快速上手 <getting_started>` 章节，以下为关键步骤摘要：

1. **环境准备**：安装 ``oebuild`` 工具与 Docker，并完成 Docker 权限配置。具体支持的平台与依赖请参阅 :ref:`快速上手 <getting_started>` 中的环境准备部分。

2. **初始化构建环境**：运行 ``oebuild init`` 初始化工作目录并拉取构建容器，所有后续构建均在该工作目录下进行。

3. **生成构建配置**：运行 ``oebuild generate`` 选择目标平台（如 ``qemu-aarch64``），生成 ``compile.yaml`` 构建配置文件。

4. **编译镜像**：在构建目录下运行 ``oebuild bitbake openeuler-image`` 完成镜像编译。如需同时生成 SDK，可追加 ``oebuild bitbake openeuler-image -c do_populate_sdk``。

5. **获取归档镜像**：除自行编译外，也可从 `dailybuild <http://121.36.84.172/dailybuild/EBS-openEuler-Mainline/>`_ 下载 CI 归档的预构建镜像，在 ``embedded_img`` 目录中按平台选取。

.. note:: 树莓派、瑞芯微、海思等其它平台的构建流程与 QEMU 类似，仅需在 ``oebuild generate`` 阶段选择对应机器即可，具体可参阅 :ref:`南向支持 <bsp>` 章节。
