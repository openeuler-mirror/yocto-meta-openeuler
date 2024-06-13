.. _add_new_board:

======================================
新增既有厂商硬件指南
======================================

本篇章介绍如何在已有厂商下新增新硬件。

新增既有厂商硬件
==========================================================

厂家或者实例层已经有示例版的 Machine.conf 的情况下我们只需要在现有的基础上定制即可，示例层基本已经把所必须的启动相关固件等镜像做了打包实现。需要的准备工作如下：

1. 连接主机(窗口1)按照以下流程准备编译工程

    ::

      # 按照初始化工程，以下initdir可以换成自己的命名
      oebuild init initdir  # 如果用自己fork的仓库可以加 -u <url> -b <branch> 指定自己链接与分支
      # 下载必须layer以及docker
      cd initdir && oebuild update
      # 新增开发板的oebuild单板配置：在yocto-meta-openeuler/.oebuild/platform/下参考对应的模板内容新建一个自己命名的板子，如xyz-abcd.yaml。
      cd src/yocto-meta-openeuler/.oebuild/platform/; cp orangepi5.yaml xyz-abcd.yaml
      # 修改xyz-abcd.yaml的内容machine变量为自己的机器名如xyz-abcd，修改后返回，创建并进入编译环境。
      cd -; oebuild generate -p xyz-abcd;cd build/xyz-abcd && oebuild bitbake

2. 打开窗口2或者vscode，切换到主机的initdir/src/yocto-meta-openeuler，在bsp/meta-openeuler-bsp/conf/machine下，参考其他的已存在的模板，新增自己板子的xyz-abcd.conf，引用默认配置后修改参数主要如下：
    
- KERNEL_DEVICETREE: 设备树名，也就是传递过去make的构建设备树目标，如果需要构建特殊镜像如rockchip的boot.img可以指定ROCKCHIP_KERNEL_DTB_NAME。
- UBOOT_MACHINE：指定uboot编译使用的defconfig。
- KBUILD_DEFCONFIG：内核的defconfig预配置，如果是rk的3399，3568，3588也可以置空，此时会由OPENEULER_KERNEL_CONFIG决定传进去的文件。
- WKS_FILE：用于创建分区映像文件的位置；可以自己增加自定义的WKS_FILE以解决具体的分区大小等信息。（可选，用于定义wic镜像）

增加自定义设备树与内核配置：

    ::

      # 完成上述操作后，在容器环境（窗口1）中下载对应的内核
      bitbake virtual/kernel -c fetch
      # 下载完成后，在主机中（窗口2）把abcd的设备树放到内核中的对应位置
      cp abcd.dts* initdir/src/xxx-kernel/arch/<对应架构>/boot/dts/<vendor>/
      # 在主机中（窗口2）如果上面指定了KBUILD_DEFCONFIG，请把对应的文件复制过去
      cp xxxx_defconfig initdir/src/xxx-kernel/arch/<对应架构>/configs/
      # 编译镜像：在容器环境（窗口1）中编译镜像，然后烧录测试
      bitbake openeuler-image
      # 如果希望在社区中开源可以把社区的xxx-kernel fork到自己仓库，把增加了设备树的内核仓库推到自己仓库，并提PR即可
