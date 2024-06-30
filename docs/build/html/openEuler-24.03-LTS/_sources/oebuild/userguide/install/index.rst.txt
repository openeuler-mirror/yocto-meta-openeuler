.. _oebuild_install:

安装步骤
########

.. note::

   - oebuild 基于 python3 实现，建议使用 **python>=3.10** 的版本。

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

**2. 安装oebuild**

oebuild从0.0.41版本开始已经支持对openEuler Embedded全版本构建，安装命令如下：

   .. code-block:: console

      # 首次安装oebuild:
      $ pip3 install oebuild
      
      # 已安装过oebuild想升级到最新版：
      $ pip3 install --upgrade oebuild

      # 想要安装特定版本的 oebuild：
      $ pip3 install oebuild==<version>
