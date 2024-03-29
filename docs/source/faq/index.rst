常见问题
######################################

Yocto
=========

Yocto是什么？
-----------------------------
Yocto Project是Linux基金会旗下的开源项目，可帮助开发人员跨硬件架构统一定制嵌入式Linux系统。\
Yocto提供了一个灵活的工具集合和开发环境，使得所有系统开发者可以轻松地共享技术、软件栈，配置并\
生成定制化镜像。

Yocto是如何通过配置定制Linux镜像的？
--------------------------------------
首先，我们需要一些配置文件（configuration files），它们多以conf作为后缀。这些文件中包含了全局变量、\
用户定义变量的定义以及硬件配置信息。它们告诉构建引擎BitBake需要将什么数据作为系统镜像的一部分。\
BitBake知道要将哪些数据放入镜像后，即前往指定的网址下载相应的数据，并且按照要求剪裁后合入最终镜像。\
后面这些具体工作的配置则一般由元数据（metadata）定义。

配方（Recipes）则是元数据最常见的一种形式，大多以bb作为文件后缀。一个配方会包含一系列用于构建软件包的\
设置和任务指引，具体包含：

1. 源代码的获取地址
   
2. 具体需要应用的补丁
   
3. 文件校验码
   
4. 编译选项
   
5. 软件库之间、配方之间的依赖关系等。
   
这些软件包最终会被用来合入最终的系统镜像。\
此外，Yocto最大特点之一便是它的开发模型——配方层模型（Layer Model）。\
配方一般都存在于配方层里。配方层相当于储存配方集合的仓库。通过将相关的配方集合\
在一起，我们可以将元数据模块化，隔离不相干的信息，如硬件相关的构建配置。\
同时，配方层是有层级的，后加入的层级可以覆盖以前加入的层级的配方内容。

Poky与Yocto的关系是什么？
---------------------------------
Poky是Yocto的参考发行版，是建立在OpenEmbedded构建系统（OpenEmbedded Core层 & BitBake\
构建引擎）基础上的集成层。除了OpenEmbedded构建系统以外，还额外包含了一组元数据用于构建\
使用者自己的发行版。此外，Poky还包含了部分Yocto组件，用于协助构建流程。

注意，Poky不包含额外的二进制文件，它只是一个能将Linux源代码构建为发行版的可行例子。

为什么我们主要修改yocto-meta-openeuler目录？它属于Yocto或者Poky的一部分吗？
-------------------------------------------------------------------------------
yocto-meta-openeuler目录则是我们自己的openEuler Embedded在定制\
内核的时候所必须的相关配置和工具的集合。它包含了属于本项目独特的配方层meta-openeuler等。\
我们在演进操作系统版本的时候，由于考虑到系统稳定性的问题，构建系统的底座\
尽量少做改动，所以基础配方层“meta-oe”和“meta”以及相关工具虽然也会更新，\
但是周期较长，大约半年到一年的时间。而我们可以通过修改独有的配方文件对\
基础软件包做一些小的升级改进，可以及时的修补漏洞，提升性能等。此外，\
我们也可以往yocto-meta-openeuler目录添加一些额外的层以及工具，用于增加功能。

openEuler Embedded构建于Poky之上，而Poky则是Yocto组件和OpenEmbedded Core的集成层。\
在构建镜像的时候，属于OpenEmbedded Core的基础配方层“meta-oe”和“meta”提供了\
很多软件包的基础配置，openEuler Embedded独有的配方文件则在之后加入，并使用之前的配置。\
如果遇到需要更新的情况，则独有的配方层里的内容可以覆盖基础配方层里的内容。如果只是需要进行微调，\
不一定需要使用bb文件，也可以使用bbappend文件。

综上，从开源项目的角度来说，openEuler Embedded是独立开源项目，但是使用了Poky项目里的\
相关技术作为底座。从开发模型来说，yocto-meta-openeuler目录包含的配方层在Yocto的层级模型里\
高于OpenEmbedded Core，因此openEuler Embedded的独有配方层依赖于这些基础配方层。\
如果独有配方层中有重复的配置，则可以覆盖基础配方层中的配置，比如定义更新或者更旧的软件包版本。

基于Yocto的项目的工作流程是什么样的？
----------------------------------------
1. 开发者指定系统架构，策略，补丁和配置细节。

2. 构建系统从配方文件指定的地方拉取源代码。

3. 代码下载到本地后，解压到本地工作区并进行相应的修改和操作（打补丁，执行配置和编译等）。

4. 构建系统将编译后的软件安装到临时的待命区（staging area），并且按照自定义的格式（deb，rpm，ipk）进行打包。

5. 整个构建过程会进行不同的质量保证和健全性测试。

6. 当二进制文件生成后，构建系统会生成一个二进制数据包用于创建最终的根文件系统。

7. 构建系统在生成根文件系统的同时，也会生成一个定制化的可扩展的SDK用于基于生成的定制化Linux的应用程序开发。

openEuler Embedded是否支持软件包安装以及如何新增软件包？
-------------------------------------------------------------------
openEuler Embedded当前是基于Yocto构建的，而Yocto是支持软件包的，但其支持方式并不是像服务器系统或者桌面系统那样，可以默认通过dnf或者apt命令来安装软件包。
由于openEuler Embedded一般面对的场景是没有显示，没有输入，且软件的成分运行过程中基本不会发生变化，例如路由器、工业控制器、机器人控制器等，所以默认生成的镜像
中不带有软件包管理器，因此无法运行dnf或apt命令来安装新的软件包。

Yocto其实在构建过程中本来就是按照软件包的形式来构建的，构建的成果按照软件包的形式打包（rpm或者deb或者ipk），然后按照软件包安装的方式的构建出根文件系统rootfs，然后
再把根文件系统其与其他部件打包成可以烧录或者安装的系统镜像。软件包管理器也是个软件包，因此也可以集成到镜像中，从而用户可以通过dnf或apt命令来安装软件包。但需要注意的是，
一方面使能软件包管理器需要更多的存储资源，例如一个几十MB大小的系统镜像基本上就无法容纳软件包管理器；另一方面，就算有了软件包管理器，也无法使用服务器系统或者桌面系统的软件包
源来安装软件包，这是因为嵌入式系统与服务器系统、桌面系统的由于构建方式的不同，导致在软件包数据库的元数据上有着巨大的差异，例如软件包的组成、软件包拆包的规则、具体版本等等。
嵌入式系统需要使用构建过程中产生的软件包元数据作为基准。

Yocto当前支持的软件包格式有rpm、deb和ipk，但openEuler Embedded为了与openEuler其他场景保持一致，目前只支持rpm格式和dnf软件包管理器。

在openEuler Embedded实现新增软件包有如下方式：

1. 查询openeuler Embedded的软件包manifest文件，确认所需要的软件包是否以集成到openEuler Embedded中：

    - 如有则把相应的软件包加入到镜像的配方文件中，重新生成镜像，并更新镜像。或者通过其他方式如使用dnf配合专门的软件包源实现增量更新。

    - 如manifest文件中没有，则需要适配新的配方，这些配方可以参考yocto-poky、yocto-meta-openeuler乃至其他yocto生态，再结合openEuler的软件包仓库，具体可以参考
      openEuler Embedded已集成的软件包实现，如busybox, core-utils等。

2. 如实在需要在openEuler Embedded中安装服务器或者桌面系统的软件包，则可以在openEuler Embedded中通过轻量级容器运行时isulad运行一个服务器或者桌面系统的容器镜像，在里面
   通过dnf或者apt来安装所需要的软件包，从而实现兼容服务器或者桌面系统生态。此时openEuler Embedded为一个支持容器的Host OS。

Oebuild
==========

Oebuild和Yocto之间的关系
-------------------------------
Oebuild是openEuler Embedded项目旗下的开源项目之一，作为基于docker的工具，\
简化了构建openEuler Embedded定制化的镜像的流程。\
Oebuild将基于Yocto的开发流程中需要手动配置但是较为机械化的步骤整合了起来，\
实现了一键配置构建镜像所需的顶层配置文件，一键生成镜像等操作。

在构建的时候，开发者可以通过Oebuild提供的相关命令快捷的生成顶层配置文件（conf文件）。\
之后，Oebuild会调用BitBake引擎，完成Yocto的工作流程，并最终输出镜像文件。

Oebuild为什么使用容器进行构建？
----------------------------------
在构建的时候，由于需要进行交叉编译，我们会需要用到特定的编译工具链，但是主机环境很可能\
已经存在一些编译工具链。如果直接进行构建，则可能出现编译路径冲突的问题，或者影响主机环境\
中其他的一些依赖于已有编译工具链的进程运行。为了创建纯净的编译环境，我们使用容器将构建\
环境与主机环境进行隔离，所以不论主机已有的编译环境如何，用户都可以不受影响的编译生成\
指定的目标镜像、软件包或者SDK，同时也不会影响主机环境。

Oebuild构建时如何避免受到上游社区的影响？
--------------------------------------------------
openEuler Embedded在构建时有许多软件包依赖上游社区，我们无法控制软件包的更新\
时间节点，抑或是更新内容。有时，不兼容更新确实会导致OS镜像构建失败。Oebuild引入\
“基线”功能，解决了这一问题。在构建镜像的时候，我们可以依照“基线”中定义的版本拉取相应的\
软件包和补丁，即使上游社区的软件包更新，也不会改变我们生成的镜像中的软件包版本。

“基线”的现实载体是manifest.yaml，里面的字段commit会指定\
某软件包相应的版本。在上游仓库中拉取软件包源码的时候，我们会根据相应的commit ID拉取相应的源码，\
保证构建的稳定性。

为什么我运行了oebuild update以后，重新构建相同特性和架构的镜像却会失败？
----------------------------------------------------------------------------
首先，oebuild目前的容器镜像是以目录为单位的，而目录又是以特性和架构为参考。如果构建相同特性和架构的镜像，\
构建目录会与以前的目录相同，所以使用的构建容器也与以前相同。那么，上次构建遗留下来的临时文件，也会存在于之前的\
容器中。

由于oebuild在运行时依赖于自己生成的某些缓存文件，而\ ``oebuild update``\命令并不会更新相关的\
缓存文件，而是只更新仓库和容器。所以此时再进行构建，则部分旧缓存会影响构建进程导致误报。比较好的解决\
办法是，在重新构建时运行命令\ ``oebuild bitbake [the image name] -c cleanall``\。这条命令会在\
执行bitbake之前执行\ ``-c``\指定的命令，将所有缓存清除后再进行构建，这样就可以避免此问题。