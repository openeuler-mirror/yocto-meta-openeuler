# yocto-meta-embedded

## 介绍

yocto-meta-embedded是用于构建openEuler Embedded所需要的一系列工具、构建配方的集合，
以及当前openEuler Embedded开发使用文档的承载仓库。

yocto-meta-embedded核心是构建Yocto Poky之上，但针对openEuler Embedded的需求做了大
量的定制化的修改，包括但不限于:

* 与openEuler其他场景的Linux, 共享软件包，共演进
* 采用预先构建的工具链和libc库，以加速构建
* 尽可能采用预先构建好的主机工具，以加速构建，同时采用容器化的构建
* 针对嵌入式场景做相应的优化

## 软件架构

* **scripts** 为一系列辅助工具，帮助好构建环境，如下载代码仓、创建构建环境等等
* **meta-openeuler** 为构建openEuler Embedded所创建的Yocto层，包含相应的配置、构建配方等等
* **bsp** 为openEuler Embedded的BSP(Board Support Package)抽象层，包含当前openEuler Embedded所支持的硬件BSP, 如QEMU、树莓派4B等
* **RTOS** 为openEuler Embeddd的RTOS(Real-Time Operating System)抽象层，主要针对Linux和RTOS混合关键部署的场景，当前支持RT-Thread和Zephyr
* **docs** 为openEuler Embedded使用和开发文档， CI会自动构建文档，并发布在如下地址：

    [**openEuler Embedded开发使用文档**](https://openeuler.gitee.io/yocto-meta-openeuler)

## 快速上手

当前只支持在Linux环境下构建openEuler Embedded。

1. 创建目录，推荐布局如下：
```
<openEuler Embedded构建顶层目录>
├── build  实际构建目录
├── tools  交叉工具链所在目录
├── src    openEuler Embedded所有代码包目录
```
2. 在src目录下，git clone本仓库，并切换到最新开发分支，当前为**openEuler-22.03-LTS**
3. 通过工具脚本下载当前所支持的软件包仓库，如下所示，该工具会git clone所有软件包仓库
```shell
    cd src
    source yocto-meta-openeuler/scripts/download.sh <path-to-src>
```
4. 从如下地址下载交叉编译工具链，并解压在**tools**目录下

    [**openEuler Embedded交叉编译工具链**](https://gitee.com/openeuler/yocto-embedded-tools/releases)

    解压后的目录如下：
```
<openEuler Embedded构建顶层目录>
├── tools  交叉工具链所在目录
    ├── openeuler_gcc_arm64le
```
5. 在build目录下调用工具脚本准备好Yocto构建环境，如下所示：
```shell
    cd build
    source ../src/yocto-meta-openeuler/scripts/compile.sh <平台名称> <build目录路径> <交叉编译工具链路径>
```
 之后便可以运行 **bitbake <目标，例如openeuler-image-tiny>** 开始构建

6. 由于openEuler Embedded采取了**尽可能不构建主机工具**的策略，因此在构建主机上需要实现准备好相应的工具，具体所需要的工具可以从**src/yocto-meta-openeuler/meta-openeuler/conf/local.conf.sample**中的**HOSTTOOLS_XXX**相关变量中获得，另一种推荐的方法是采用容器构建，具体如下：

    [**openEuler Embedded容器构建**](https://openeuler.gitee.io/yocto-meta-openeuler/yocto/quickbuild/container-build.html)

## 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request
