.. _oebuild_install:

安装步骤
########

.. note::

   - oebuild 基于 python 实现，支持最低的 python3 版本为 **python3.8**。

   - 当前 **仅支持在64位的x86环境** 下使用 oebuild，并且需要在 **普通用户** 下进行 oebuild 的安装运行。

**1. 安装并配置依赖**

   .. tabs::

      .. code-tab:: console openEuler

         # 安装必要的软件包
         $ sudo yum install python3 python3-pip docker

         # 配置docker环境
         $ sudo usermod -a -G docker $(whoami)
         $ sudo systemctl daemon-reload && sudo systemctl restart docker
         $ sudo chmod o+rw /var/run/docker.sock

      .. code-tab:: console Ubuntu

         # 安装必要的软件包
         $ sudo apt-get install python3 python3-pip docker docker.io

         # 配置docker环境
         $ sudo usermod -a -G docker $(whoami)
         $ sudo systemctl daemon-reload && sudo systemctl restart docker
         $ sudo chmod o+rw /var/run/docker.sock

      .. code-tab:: console SUSELeap15.4

         # 安装必要的软件包
         $ sudo zypper install python311 python311-pip docker

         # 配置docker环境
         $ sudo usermod -a -G docker $(whoami)
         $ sudo systemctl restart docker
         $ sudo chmod o+rw /var/run/docker.sock
         $ sudo systemctl enable docker

         # 配置最新版python
         $ cd /usr/bin
         $ sudo rm python python3
         $ sudo ln -s python3.11 python
         $ sudo ln -s python3.11 python3

**2. 安装对应版本的oebuild**

  针对不同的 openEuler Embedded 版本，需要安装对应版本的 oebuild。
  openEuler Embedded 的版本与 `yocto-meta-openeuler <https://gitee.com/openeuler/yocto-meta-openeuler>`_ 仓库的分支是一一对应的，相关联的 oebuild 版本信息如下：

  .. _oebuild_version:

  .. list-table::
     :widths: 40 35
     :header-rows: 1

     * - openEuler Embedded 版本
       - oebuild 版本
     * - master
       - latest
     * - openEuler-23.09
       - 0.0.32
     * - openEuler-22.03-LTS-SP2
       - 0.0.27

  执行以下命令安装 oebuild：

  .. code-block:: console

     # 对于 master 分支，安装最新版本的 oebuild：
     $ pip3 install --upgrade oebuild

     # 对于其它分支，安装 <version> 版本的 oebuild：
     $ pip3 install oebuild==<version>

