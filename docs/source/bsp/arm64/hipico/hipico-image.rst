.. _hipico-image:

HiPico镜像构建
#####################

.. note::

   相关文档
   
   openeuler官方文档：:ref:`getting_started`

1.检查基本开发环境
--------------------

开发建议使用ubuntu系统，需要先安装ubuntu系统并配置基本的ubuntu开发环境。

openeuler的构建都在docker中进行，因此对系统的依赖只有docker和python。其中python版本最低为\ **python3.8及以上**\ ，建议python版本越新越好。若当前系统中没有指定版本的python，建议使用\ **conda**\ 创建虚拟的python环境。

.. code:: bash

   # 安装docker
   sudo apt-get install docker docker.io
   # 配置docker环境
   sudo usermod -a -G docker $(whoami)
   sudo systemctl daemon-reload && sudo systemctl restart docker
   sudo chmod o+rw /var/run/docker.sock

.. code:: bash

   # 若当前主机包含python3.8及以上版本的python可直接执行以下命令安装oebuild
   # 若不包含指定版本，参考conda使用手册安装虚拟环境后在虚拟环境中安装oebuild
   pip install oebuild

2.初始化构建环境
------------------

oebuild是openeuler构建开发环境的工具，可以根据配置自动拉取docker镜像、源码、初始化构建环境等操作。

.. code:: bash

   # 创建工作目录
   oebuild init <work_dir>
   # 切换到工作目录
   cd <work_dir>
   # 拉取构建容器、yocto-meta-openeuler 项目代码
   oebuild update

   # 创建hipico构建环境
   oebuild generate -p hipico -d build_arm64

3.构建openeuler镜像
---------------------

.. code:: 

   <work_dir>
       ├── build
       │   └── build_arm64				# 构建目录
       └── src
           ├── yocto-meta-openeuler	# openeuler主仓库
           ├── ...						# 其它源码仓库

构建openeuler系统需要切换到\ **构建目录**\ ，再执行命令。

.. code:: bash

   # 切换到构建目录
   cd <work_dir>/build/build_arm64
   # 编译openeuler镜像
   oebuild bitbake openeuler-image

构建完成后，在\ ``<work_dir>/build/build_arm64/output/<构建时间戳>``\ 目录中生成构建产物。

.. code:: 

   -rwxr-xr-x 1 cxcc cxcc   8600124 Oct 22 13:12 Image
   -rw-r--r-- 1 cxcc cxcc   8600124 Oct 24 15:02 Image-5.10.0-openeuler
   -rw-r--r-- 1 cxcc cxcc  38615170 Oct 24 15:02 openeuler-image-hipico-20241024150144.rootfs.cpio.gz
   -rw-r--r-- 1 cxcc cxcc 133066752 Oct 24 15:02 openeuler-image-hipico-20241024150144.rootfs.ext4
   -rw-r--r-- 1 cxcc cxcc  57671680 Oct 24 15:02 openeuler-image-hipico-20241024150144.rootfs.ubi
   -rw-r--r-- 1 cxcc cxcc   3635101 Oct 22 13:13 uImage
   -rwxr-xr-x 1 cxcc cxcc   9456744 Oct 22 13:12 vmlinux
   -rw-r--r-- 1 cxcc cxcc   6140008 Oct 24 15:02 vmlinux-5.10.0-openeuler
   lrwxrwxrwx 1 cxcc cxcc        23 Oct 24 15:02 zImage -> zImage-5.10.0-openeuler
   -rwxr-xr-x 1 cxcc cxcc   3618248 Oct 22 13:13 zImage-5.10.0-openeuler

其中\ ``uImage``\ 和\ ``openeuler-image-hipico-20241024150144.rootfs.ubi``\ 分别是内核和根文件系统的部署件，可通过烧录工具直接烧录到系统中。

.. note::

   **怎么获取u-boot?**

   可在以下仓库链接中获取u-boot源码：

   https://gitee.com/hieuler-pico/u-boot

   若对u-boot功能没有特殊要求可直接下载最新的releases版本：
   
   https://gitee.com/hieuler-pico/u-boot/releases

.. note::

   **怎么烧录固件?**

   首先需要获取所有的部署件：

   .. code:: 

      1. burn_table.xml: 烧录分区表
      2. boot_image.bin: u-boot镜像
      3. nand_env.bin: u-boot环境变量
      4. uImage: Linux内核镜像
      5. openeuler-image-hipico-*.rootfs.ubi: 根文件系统镜像

   参考 :ref:`hipico-burn` 烧录固件
