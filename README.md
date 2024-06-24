# yocto-meta-openeuler

## 介绍

openEuler Embedded的构建工具基于Yocto Poky Project。Poky是Yocto Project的参考发行版。在Yocto Project里，一个很重要的概念是配方层模型（Layer Model）。我们可以将一些相关的配方放入同一个配方层，简化定制流程。后加入的层级里的配方可以覆盖已经加入的层级里存在的配方。

yocto-meta-openeuler是用于构建openEuler Embedded的一系列构建配方的集合，也就是配方层的集合，以及包含相关构建工具和openEuler Embedded的开发使用文档。通过修改yocto-meta-openeuler中的配方层，如meta-openeuler，我们针对openEuler Embedded实现了大量定制化的需求，包括但不限于:

* 与openEuler其他场景的Linux共享软件包，共演进。
* 采用预先构建的工具链和libc库，以加速构建。
* 尽可能采用预先构建好的主机工具，以加速构建，同时采用容器化的构建。
* 针对嵌入式场景做相应的优化。

## 目录架构

* **scripts** : 一系列辅助工具，用于帮助构建环境，如下载代码仓、创建构建环境等等
* **meta-openeuler** : 构建openEuler Embedded所创建的Yocto层，包含相应的配置、构建配方等等
* **bsp** : openEuler Embedded的BSP(Board Support Package)抽象层，包含当前openEuler Embedded所支持的硬件BSP, 如QEMU、树莓派4B等等
* **RTOS** : openEuler Embeddd的RTOS(Real-Time Operating System)抽象层，主要针对Linux和RTOS混合关键部署的场景，当前支持RT-Thread和Zephyr
* **docs** : openEuler Embedded使用和开发文档， CI会自动构建文档，并发布于如下地址：

    [**openEuler Embedded开发使用文档**](https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/)

## 快速上手

使用oebuild快速构建openEuler Embedded

当前只支持在X86 64位的Linux环境下构建openEuler Embedded。具体操作见说明文档：

[**使用oebuild快速构建openEuler Embedded**](https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/oebuild/index.html)

oebuild会自动在src目录下git clone本仓库，默认切换到最新开发分支，即**master**。

oebuild构建后会自动生成如下目录结构：
```
<openEuler Embedded构建顶层目录（自己创建的目录）>
├── build  实际构建目录
    ├── output  镜像输出目录
    ├── tmp  构建工作临时文件目录
├── src    openEuler Embedded所有代码包目录
```


## 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支 (名称对应需要开发的特性)。每个特性使用一个单独的分支，好处是可以同时开发多个不相干的特性，并且新建pull request的时候互不影响。减少了代码仓管理的复杂度。
3.  提交代码到自己的仓库：

    一个合格的git提交信息如下所示，请尽可能在提交信息中描述相关信息，例如改动的地方，修改的原因，如何验证等等。（需要替换的内容用“[]”包含，实际提交信息中不用包含“[]”）

    ```
    [module name, e.g. docs]: [git commit msg titile (what to change)]

    [git commit msg body (detailed explaination of what to change, why to change, and even how to verify)]

    Signed-off-by: [name] <[email]>
    ```

    本仓库采用了gitlint检查每次git提交，建议提交前使用 [**gitlint**](https://jorisroovers.com/gitlint) 检查您的提交，以避免CI门禁检查失败．

4.  新建 Pull Request，等待审查并将代码合并到本仓库（可以选择合并后删除用于开发的分支）
