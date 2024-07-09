.. _openeuler_fetch:


通过openeuler_fetch使用openEuler软件包
==========================================

特性介绍
***************************

在openEuler Embedded构建镜像时，不需要提前下载所有软件包。功能函数openeuler_fetch在openEuler Embedded构建镜像时，按需从上游源码包自动下载软件包。例如当你只想编译busybox这一个软件包，而不需要将其他软件包全部下载的时候，使用openeuler_fetch即可实现，你只需要初始化完环境即可进入编译环节。

openeuler_fetch运行机制
***************************

openeuler_fetch在classes/openeuler.bbclass中实现，函数名为do_openeuler_fetch，该函数在base_do_fetch:prepend中通过bb.build.exec_func()函数调用，即openeuler_fetch运行完还会继续执行do_fetch，这样做的原因是不管openeuler_fetch运行成功与否都可以让fetch继续补充，例如有一款软件包在gitee中不存在，或在配置中配置错误，或者源码目录有相关的改动导致openeuler_fetch运行失败，不用担心，do_fetch可以继续完成文件的查找。

openeuler_fetch运行逻辑
***************************

openeuler_fetch通过以下控制变量来完成相关包下载：

 - OPENEULER_REPO_NAME: 软件包名，该名一般和构建包名一致，但在特殊情况下需要改动，例如构建libtool-cross时，构建包名为libtool-cross，因此默认OPENEULER_REPO_NAME为libtool-cross，但是依赖包路径是libtool，则需要将OPENEULER_REPO_NAME改为libtool

 - OPENEULER_LOCAL_NAME: 软件包本地名称，即软件包在本地路径名称，一般该变量如果不设置则在系统处理时默认和OPENEULER_REPO_NAME一样，该变量意在解决软件包名和本地存储路径不一致问题

 - OPENEULER_REPO_NAMES: openeuler_fetch调用时实际用到的变量名，默认设置为OPENEULER_LOCAL_NAME，可追加不同的软件包名到此变量实现多仓下载

整体openeuler_fetch下载就是依靠以上相关变量确定下载的包信息，而获取下载包的信息是在openEuler Embedded的基线文件中记录的，该文件目录为.oebuild/manifest.yaml，如果在基线文件中能命中该包信息，则会进行下载，否则不做任何操作。基线文件中的包信息包含该包的version，因此在命中该包后会根据version来确定该包的版本，并且为了更快的完成下载任务，我们尽可能的减少下载的代码量，因此openeuler_fetch在下载代码时其深度设定为1。在对该包的匹配过程中，如果本地可以检出该包的version，则直接切换包版本，否则进行fetch操作，然后再进行包版本检出。

另外openeuler_fetch对于OPENEULER_REPO_NAME与OPENEULER_LOCAL_NAME的处理为如果设定了OPENEULER_LOCAL_NAME则选用OPENEULER_LOCAL_NAME作为reponame，用reponame来查找manifest.yaml中的相关包信息，否则选用OPENEULER_REPO_NAME作为reponame，因此对于同一个仓，由于不同的应用场景需要选用不同的分支，那么则需要设定不同的OPENEULER_LOCAL_NAME。

例如特性M与N，都依赖a仓，但是版本分支不同，因此对于M来说，其所设定的a仓的OPENEULER_LOCAL_NAME为a-1，对于N来说，其所设定的a仓的OPENEULER_LOCAL_NAME为a-2，而manifest.yaml中需要各自记录a-1与a-2的版本信息。

如何适配其他软件包
***************************

在构建openEuler Embedded时经常会引入其他相关包或修改非指定包版本，那么此时该如何做呢？直接修改基线文件即可，内核是例外，接下来我们分以下几种情况进行讲解。

**情形一：配方名和仓库名一致，我们以busybox为例进行讲解**

我们查看manifest.yaml中busybox的信息

.. code:: 

    busybox:
        remote_url: https://gitee.com/src-openeuler/busybox.git
        version: aa2fc58263cf357d0c2f4f30118f3b4614fa25f6

- 如果想要某一个版本的busybox参与构建：在manifest.yaml中将busybox的version进行修改即可

- 如果想要使用自有仓库的busybox参与构建：在manifest.yaml中将remote_url修改为自有仓库的链接即可

- 如果需要其他代码仓的busybox参与构建：同理，直接在manifest.yaml中修改对应的busybox中remote_url即可

**情形二：配方名和仓库名不一致，我们以libpcre2为例进行讲解**

我们查看manifest.yaml中libpcre2的git信息

.. code:: 

    pcre2:
        remote_url: https://gitee.com/src-openeuler/pcre2.git
        version: 82f14dfaf634ca8ae076aef7a19c65136c4e4a3d

可以看到其key键是pcre2，那么这种情况是因为其bbappend文件中设置了OPENEULER_REPO_NAME或OPENEULER_LOCAL_NAME，关于这两个变量的使用请参考上文“openeuler_fetch运行机制”，这里不再详述，下面附上其代码范例：

.. code:: 

    # main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb

    # version in openeuler
    PV = "10.42"
    LIC_FILES_CHKSUM = "file://LICENCE;md5=41bfb977e4933c506588724ce69bf5d2"

    OPENEULER_REPO_NAME = "pcre2"


前文提到，如果设置了OPENEULER_REPO_NAME或OPENEULER_LOCAL_NAME则会以这两个变量内容为准进行仓库信息查找。

**情形三：构建依赖不通过depends指定，而是通过SRC_URI指定**

构建一个软件包时可能会从多个仓下获取源码，即不能直接通过depends添加依赖，此时需要设置OPENEULER_REPO_NAMES，追加需要依赖的包，例如：

.. code::

    # multi-repos are required to build dsoftbus
    OPENEULER_REPO_NAMES = "yocto-embedded-tools dsoftbus_standard embedded-ipc dsoftbus"

通过OPENEULER_REPO_NAMES设置好需要依赖的包，同时列表中的包需要在manifest.yaml中有相关信息的记录，以以上的列表为例，我们需要在manifest.yaml中有关于yocto-embedded-tools的包信息，
否则不会有任何下载功能，OPENEULER_REPO_NAMES变量的设定是为在do_openeuler_fetch中获取依赖的包列表，do_openeuler_fetch将依次解析OPENEULER_REPO_NAMES，并调用do_openeuler_fetch完成相关包的下载。

如何关闭openeuler_fetch功能
***************************

OPENEULER_FETCH有两种关闭方式：

1. 在meta-openeuler/conf/layer.conf中有一个全局变量OPENEULER_FETCH，该值默认为enable，即openeuler_fetch是开启状态，如果想要关闭openeuler_fetch，设置该值为disable即可。

2. 在oebuild执行generate指令时，将参数-df带上，也可以关闭openeuelr_fetch功能

另外 ``OPENEULER_FETCH`` 该值的作用域是全局的，我们在开发中可能会针对某一些包不需要运行openeuler_fetch，则可以在相关包的bb或bbappend中设定该值为disable
