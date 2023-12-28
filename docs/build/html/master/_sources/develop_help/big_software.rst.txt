.. _big_software:


上游源码包不存在如何解决
========================

openEuler Embedded的软件包组成在设计之初是全部来源于openEuler社区，然而在实际项目发展过程中对于该前提条件存在一定的不确定性以及实施的困难性。
原因就在于openEuler上游软件包虽然覆盖了几乎所有的openEuler Embedded所需软件包，但仍然有一些特殊软件包并没有被收录到openeuler中，针对既需要
一些特殊包，而openeuler未收录，并且还要遵循openEuler Embedded的软件包来源策略，我们在openeuler下创建了oee_archive仓库，该仓库的作用就是为了
解决这样的特殊场景。oee_archive仓库用来放置openEuler Embedded所需的上游源码压缩包，同时为了针对oee_archive仓库的下载更加快速，有效，我们
专门实现了oee_archive_download方法来应对。oee_archive的仓库地址为：https://gitee.com/openeuler/oee_archive.git

现在将为您添加一个新包提供指导：

1. 在openeuler组织下查询想要添加的包名，如果存在则按正常流程修改bb文件或bbappend文件，否则进行下一步
2. 找到对应包的bb文件，从SRC_URI中识别出相应的源码链接，一般该链接的以https或者git开头的压缩文件链接

.. note::

    这里需要注意的是，在yocto中，常用的元数据层来源于两个层，一个是poky，另一个是openembedded层，然后不同的特性也有其各自的元数据，因此
    需要自行识别出需要添加的软件包来源于哪个层

3. 手动下载找到的上游源码压缩包链接，如果上游给出的是git链接，则在下载后需要手动进行压缩
4. 在自己的gitee账户下fork一个oee_archive仓库，如果这一步已做则忽略，具体如何操作请自行查询相关信息
5. 在本地对oee_archive仓库做好提交环境
6. 添加上游软件包到oee_archive，然后进行提交并提交到上游oee_archive。

.. note::

    压缩包的提交需要遵循一定的规则，即需要在该包上层创建这个包名的文件夹，这里举个例子：
    假设需要针对honey包进行提交其源码压缩包，其源码压缩包为honey-10.0.tar.gz，其对应的bb文件为honey_10.0.bb，那么需要在oee_archive根
    目录下应该这样放置源码压缩包
    
    `./honey/honey-10.0.tar.gz`
    
    这样做是为了应对oee_archive的下载，具体可以查看openeuler_fetch章节

1. 待oee_archive的添加包pr合入后需要对yocto-meta-openeuler中的基线文件manifest.yaml进行更新

2. 至此上游源码压缩包的添加已经完成

在上游源码包添加完成后该如何在bb文件或bbappend文件中适配呢？下面给出指导：

1. 一般来说我们引入上游包时会有对应的bb文件，只是该bb文件中对源码的指向需要进行切换，使其指向到oee_archive仓库下，因此我们需要添加
   对应包的bbappend文件，具体其应该放置的路径这里不再详述。
2. 在bbappend文件中我们需要对SRC_URI进行定制化修改，将原有的指向源码的那一行去掉或使其不再生效，如何做呢？
   
   - 其一是添加OPENEULER_SRC_URI_REMOVE变量，该变量会在do_fetch阶段生效，即如果设置了该变量，在do_fetch时，关于设置在该变量开头的协议将会被忽略

    例如：
    
    .. code:: 

        OPENEULER_SRC_URI_REMOVE = "https git"

   - 其二是在SRC_URI添加remove组合，将上游源码指向的链接remove掉。
   
    例如：

    .. code:: 

        SRC_URI:remove = "https://xxxxxxxxxxxxxx \
            git://xxxxxxxxxxxxxx\
        "

    两种方法任选其一，推荐第一种

3. 将上游源码压缩包添加到SRC_URI中，同时需要在SRC_URI前面指定OPENEULER_LOCAL_NAME="oee_archive"，参考如下范例：

    .. code:: 

        OPENEULER_SRC_URI_REMOVE = "https git"
        OPENEULER_LOCAL_NAME = "oee_archive"
        SRC_URI:prepend = "file://${OPENEULER_LOCAL_NAME}/${PBN}/xxxxxxxx \
        "
    
    在SRC_URI中使用prepend是因为需要将源码压缩包放在最前面，而使用${PBN}是因为在向oee_archive添加包时，我们前面说过，
    需要在上层创建包名的文件夹，所以在压缩包前面添加${PBN}
4. 如果原bb文件中有对压缩包的sha256或者md5的校验验证，还需要自行进行更新，压缩包的校验方法为 `sha256sum xxx` 或 `md5sum xxx`

至此，一个完整的添包流程就完成了，如果在构建中出现编译等的报错，则需要自行细细研究去解决
