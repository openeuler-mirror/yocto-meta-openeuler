.. _add_package_src:

如何添加或修改软件包源
======================

在新添加包时出于openEuler Embedded的软件包来源策略使得我们要添加的软件包必须来源于上游openEuler社区，因此这里针对如何替换包源为openEuler源做出指导，我们着重考虑以下几种场景。

**场景一：所添加的包在上游openEuler存在**

所添加软件包在上游openEuler中存在，这就需要我们以openEuler中的包源为准。现在将为您提供添加一个包源的指导：

1. 从对应bb文件中的SRC_URI中识别出相应的源码链接，一般该链接是以https或者git开头的。
2. 在src-openeuler中找到对应包的仓库，确定版本号。
3. 添加对应包的bbappend文件，并在manifest.yaml中添加包的git信息，按如下范例添加：

    .. code:: 

        libxcb:
            remote_url: https://gitee.com/src-openeuler/libxcb.git
            version: a8fbea0090769fe5e80962aed7bd14216a4274cf
        ...

    我们拿libxcb来举例说明，remote_url是远程仓地址链接，version是其版本号

4. 修改bbappend文件，替换原SRC_URI中源码指向的路径，按如下范例：

    .. code:: 

        # 假设源码远程链接为 https://xxxx.net/honey.tar.gz
        OPENEULER_SRC_URI_REMOVE = "https"
        # 假设openEuler中该包名称为honey-4.0.tar.gz
        PV = "4.0"
        SRC_URI:prepend = "file://honey-${PV}.tar.gz \
        "

5. 至此，新添加的包源替换完成。

**场景二：所添加的包在上游openEuler中不存在**

openEuler Embedded的软件包组成在设计之初是全部来源于openEuler社区，然而在实际项目发展过程中对于该前提条件存在一定的不确定性以及实施的困难性。原因就在于openEuler上游软件包虽然覆盖了几乎所有的openEuler Embedded所需软件包，但仍然有一些特殊软件包并没有被收录到openeuler中，针对既需要一些特殊包，而openeuler未收录，并且还要遵循openEuler Embedded的软件包来源策略，我们在openeuler下创建了oee_archive仓库，该仓库的作用就是为了解决这样的特殊场景。oee_archive仓库用来放置openEuler Embedded所需的上游源码压缩包，同时为了针对oee_archive仓库的下载更加快速、有效，我们专门实现了oee_archive_download方法来应对。oee_archive的仓库地址为：https://gitee.com/openeuler/oee_archive.git

现在将为您添加一个新包提供指导：

1. 先按正常流程修改bbappend文件，即查找到上游原bb文件，然后创建对应的bbappend文件，比对新旧版本的bb文件内容，做差异化删改，这里不再详述。
2. 找到对应包的bb文件，从SRC_URI中识别出相应的源码链接，一般该链接是以https或者git开头的压缩文件链接。
3. 手动下载找到的上游源码压缩包链接，如果上游给出的是git链接，则在下载后需要手动进行压缩。git仓库压缩方式参考如下命令：
   
   .. code:: 

        git archive --format=tar.gz --prefix=git/ --output ../配方名-PV.tar.gz HEAD

4. 添加上游软件包到oee_archive，然后进行提交并提交到上游oee_archive。

    .. note::

        压缩包的提交需要遵循一定的规则，即需要在该包上层创建这个包名的文件夹，这里举个例子：
        假设需要针对honey包进行提交其源码压缩包，其源码压缩包为honey-10.0.tar.gz，其对应的bb文件为honey_10.0.bb，那么需要在oee_archive根目录下应该这样放置源码压缩包
        
        `./honey/honey-10.0.tar.gz`
        
        这样做是为了应对oee_archive的下载，具体可以查看openeuler_fetch章节

5. 待oee_archive的添加包pr合入后需要对yocto-meta-openeuler中的基线文件manifest.yaml进行更新。

6. 至此上游源码压缩包的添加已经完成。

在上游源码包添加完成后该如何在bb文件或bbappend文件中适配呢？下面给出指导：

在bbappend文件中我们需要对SRC_URI进行定制化修改，将原有的指向源码的那一行去掉或使其不再生效，如何做呢？添加OPENEULER_SRC_URI_REMOVE变量，该变量在包解析阶段会重置SRC_URI，并根据OPENEULER_SRC_URI_REMOVE中设置的协议过滤掉相关链接，同时需要在SRC_URI前面指定OPENEULER_LOCAL_NAME=”oee_archive”，参考如下范例：

.. code:: 

    #  去除SRC_URI中https与git协议开头的链接
    OPENEULER_SRC_URI_REMOVE = "https git"
    # 将包本地路径指向到oee_archive
    OPENEULER_LOCAL_NAME = "oee_archive"
    # 在SRC_URI最前面添加包源
    SRC_URI:prepend = "file://${OPENEULER_LOCAL_NAME}/${BPN}/xxxxxxxx \
    "

在SRC_URI中使用prepend是因为需要将源码压缩包放在最前面，而使用${BPN}是因为在向oee_archive添加包时，我们前面说过，
需要在上层创建配方的文件夹，所以在压缩包前面添加${BPN}


至此，一个完整的添包流程就完成了，如果在构建中出现编译等的报错，则需要自行细细研究去解决

**场景三：所添加的包来源于自建包**

如果所添加的包完全来源于自建包或者非开源包，那么在这种情况下是不被允许合入openEuler Embedded源码仓的，因此这种情况是开发者在本地环境进行开发或者在封闭环境做项目开发，这种业务场景我们分两种解决方案。其一，将源码放在私有gitee仓库。其二，将源码附在配方下。

针对第一种解决方案，参考上面“所添加的包在上游openEuler存在”章节，这里我们只对第二种情况进行详述。

1. 我们默认用户已经创建了自己的配方，这里我们着重讲的是包源的添加或替换，在对应的配方下创建files文件夹，将自建包打包成压缩包，然后放置于files下，假如自建包名为honey，版本为0.0.40，那么添加的目录结构应该如下：

    .. code:: 

        honey
        files
            honey.0.0.40.tar.gz
        honey_0.0.40.bb

2. 在bb文件中修改SRC_URI中，添加源码包路径。

    .. code:: 

        SRC_URI:prepend = "file://honey.0.0.40.tar.gz \
        "

在yocto执行do_fetch任务阶段，会自动将files作为一个默认搜索路径，至此，自建包添加包源完成。
