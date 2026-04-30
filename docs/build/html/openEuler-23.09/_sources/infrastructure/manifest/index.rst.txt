.. _manifest:

版本基线
################################

简要介绍
^^^^^^^^

嵌入式镜像在构建过程中总会需要能基于基线文件还原出某个版本镜像，这个文件应该记录的内容应该是可以还原出该镜像的所有环境参数，并有对应的工具支撑该文件的实际应用。例如该文件记录了依赖的软件包、构建环境的各项参数等，而对应的支撑工具可以通过这些个参数还原出构建环境，并能够进行构建。

openEuler Embedded也有自己的基线设施，由于openEuler
Embedded整体的构建环境相对稳定，比如编译链，sdk等等，因此目前的基线文件记录的内容主要是依赖的上游软件包列表，记录的参数有三个：包路径，remote_url以及version，范例结构如下：

::

   zlib:
       remote_url: https://gitee.com/src-openeuler/zlib.git
       version: 19f7d916543c44e2f2e8c52c81ac5d194d0573ad

zlib: 是一个key键，同时也标识在本地会创建的目录名

remote_url: 标识远程仓链接

version: 标识相应的包版本

如何获取基线快照
^^^^^^^^^^^^^^^^

openEuler Embedded获取基线快照有两种方式：

直接获取
''''''''

从官方的CI/CD的构建产物平台获取，openEuler
Embedded对支撑的镜像会进行每日定时构建，构建产物会存放在统一的平台供用户下载，那么在下载平台会有 ``manifest`` 基线文件，这里以master分支的构建产链接来讲，打开master的构建产物链接：

::

   http://121.36.84.172/dailybuild/openEuler-Mainline/openeuler-2023-04-20-13-13-45/embedded_img/

可以看到如下图所示：

.. image:: ../../../image/manifest/manifest.png

最外层表示CPU架构分类，里面有该架构下的各种单板镜像，在source_list目录下存放这该批次构建的基线文件，如下图所示：

.. image:: ../../../image/manifest/manifest2.png

manifest.yaml就是该批次构建的基线文件，而manifest.yaml.sha256sum是该文件内容的校验值

oebuild 生成
''''''''''''

可以通过oebuild工具来获取基线文件，openEuler Embedded从23.03版本开始从零散构建模式归一化为单一构建模式，摒弃了原有的复杂构建环境准备工作与构建流程，全部归拢到一个工具来简化所有准备工作。而oebuild就承担了该重任，对oebuild的介绍在这里仅限于此，不再展开，这里着重介绍一下oebuild对基线的快照命令： ``oebuild manifest`` ，该命令可以通过现有环境生成基线文件，使用如下命令即可：

::

   oebuild manifest -r -m_dir <manifest_dir>

该命令的使用必须是在oebuild的工作目录中，oebuild在执行生成基线文件命令时会遍历源码目录下所有有效的git仓，并将目录名，remote_url以及version记录到指定的manifest_dir路径的文件中，由此便获取到一个基于当下环境的基线文件，请查看如下使用方法：

.. image:: ../../../image/manifest/manifest.gif

基线维护策略
^^^^^^^^^^^^

基线文件记录着上游软件仓的版本信息，基线文件的维护需要人为主动提交pr来更新，而目前对于上游软件的更新的感知，openEuler
Embedded目前采用如下两种方式：

被动感知
''''''''

采用定时任务进行通知，定时任务的构建内容和CI完全一致，由每天定时进行构建，构建时完全屏蔽基线文件，对于上游依赖软件仓采用最新版本进行构建，构建成功时不会做任何操作，在构建失败时则会将所有构建失败的相关参数全部以issue方式进行通知，版本经理会对该issue进行实时跟踪，直至解决，常见的场景是上游软件仓有版本更新，在报构建失败发送issue后，yocto-meta-openeuler做相应的适配，并把更改后的manifest.yaml一并提交，由此完成manifest.yaml更新

如下图所示：

.. image:: ../../../image/manifest/cron.png

主动感知
''''''''

yocto-meta-openeuler依赖的layer层版本策略并不会跟随大版本节奏进行，而对于layer层的更新一般是由openEuler
Embedded开发者来做，因此如果layer层有更新，也会联动到yocto-meta-openeuler的manifest.yaml，由此完成manifest.yaml更新

.. image:: ../../../image/manifest/layer.png

基线应用
^^^^^^^^

目前基线的业务场景应用主要分为开放式环境和封闭式环境，开放式环境即在构建时网络正常可以实时从互联网下载依赖仓，封闭式环境即在构建时无法从互联网实时下载依赖仓，现在详细讲解两种业务场景的基线应用方式。

开放式环境基线应用
''''''''''''''''''

在yocto-meta-openeuler的.oebuild目录下有当下版本的manifest.yaml，在构建时会根据manifest.yaml实时下载相应版本的上游软件仓，在local.conf中默认设置了一个变量MANIFEST_DIR，该变量指向了manifest.yaml路径，在构建过程中，openeuler_fetch会实时解析manifest.yaml文件，并获取对应仓的版本参数，然后下载相应的版本源码。

MANIFEST_DIR设置位置

.. image:: ../../../image/manifest/dir.png

封闭式环境基线应用
''''''''''''''''''

封闭式环境下进行基于基线构建相对比较复杂，openEuler
Embedded的构建以构建工具oebuild为主，封闭式环境的构建需要事先准备源码，而oebuild工具有一个命令manifest，该命令可以以某个manifest.yaml为基准将依赖的代码仓还原到相应的版本，然后在执行 ``oebuild bitbake`` 之前屏蔽layer层更新就可以在封闭环境下进行构建了，详情请参照 :ref:`oebuild_install` 中manifest命令说明。

``oebuild manifest`` 还原源码教程：

.. image:: ../../../image/manifest/manifest_r.gif

屏蔽layer层更新教程：

.. image:: ../../../image/manifest/not_use_repos.gif

特殊场景处理
^^^^^^^^^^^^

如何屏蔽基线构建
''''''''''''''''

openEuler
Embedded基于基线构建的主要处理环节在执行openeuler_fetch中，对于manifest.yaml的处理逻辑是：如果没有设置MANIFEST_DIR变量或者manifest.yaml文件不存在，则不会基于基线进行版本下载。

因此如果需要屏蔽基线构建，则只需要在 ``conf/local.conf`` 文件中将MANIFEST_DIR变量注释掉或者将该变量置为空即可
