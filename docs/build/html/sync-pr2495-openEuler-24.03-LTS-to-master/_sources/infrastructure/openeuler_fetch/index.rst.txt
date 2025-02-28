.. _openeuler_fetch:


通过openeuler_fetch使用openEuler软件包
==========================================

特性介绍
***************************

在openEuler Embedded构建镜像时，所有上游软件包仓全部来自于欧拉社区，对于欧拉社区来说，其代码托管平台为gitee，一个软件包仓库不止有源码压缩包，还有对应的patch以及其他编译依赖文件，而openEuler Embedded在构建时通过SRC_URI指定了依赖文件查询地址，因此这些依赖文件需要预先准备在对应的路径下，而对于构建所依赖的上游软件包，要不一次性全部下载完全，要不在构建时按需下载，openeuler_fetch就是为了解决按需下载的理想情况。openeuler_fetch是一个类，这个类被设置为所有的bb文件都将继承，在<meta-openeuler/conf/distro/openeuler.conf>中可以看到INHERIT字段添加了openeuler。

openeuler_fetch运行机制
***************************

openeuler_fetch在classes/openeuler.bbclass中实现，函数名为do_openeuler_fetch，该函数在base_do_fetch:prepend中通过bb.build.exec_func()函数调用，即openeuler_fetch运行完还会继续执行do_fetch，这样做的原因是不管openeuler_fetch运行成功与否都可以让fetch继续补充。
在openeuler_fetch运行时，在最开始阶段，会检测是否有缓存源码，如果有则利用，否则继续执行下一步
如果下载的软件仓是oee_archive，则会进行特殊处理，这是因为oee_archive仓库主要用于存放一些欧拉社区不存在的软件包或者一些比较大的源码包，每个源码压缩包会在某个二级目录下，而对于整个oee_archive来说，一次性全部下载会很臃肿占空间而且还很耗费时间，因此会只下载指定的二级目录
如果openeuler_fetch在运行时检测到已经准备好的软件包仓（已准备好是指已正常在软件包仓检出某一个版本）存在.gitattributes，则意味着该仓存在大文件，则会默认执行git-lfs来将对应的大文件下载下来

openeuler_fetch运行逻辑
***************************

与openeuler_fetch相关的变量介绍：

 - OPENEULER_LOCAL_NAME: 软件包本地名称，即软件包在本地路径名称，该值默认与BPN保持一致，查看其定义文件<meta-openeuler/conf/distro/openeuler.conf>，但是我们有时候配方名称并不一定与软件包目录名一致，当出现这样的现象时需要设置该值，例如：对于配方astra-camera-msgs_1.0.1来说，其BPN为astra-camera-msgs，但是其仓名为：hieuler_3rdparty_sensors，则需要设置:
 
 .. code::

    OPENEULER_LOCAL_NAME = "hieuler_3rdparty_sensors"

 - OPENEULER_REPO_NAMES: openeuler_fetch调用时实际用到的变量名，默认设置为OPENEULER_LOCAL_NAME，可追加不同的软件包名到此变量实现多仓下载，名称之间用空格隔开，其真实应用代码如下：

 .. code::
    
        repo_list = d.getVar("OPENEULER_REPO_NAMES").split()
        for repo_name in repo_list:
            # download code from openEuler
            openeuler_fetch(d, repo_name)
 
 如果一个配方有涉及到多个源码包仓，则将所有的源码包仓名全部加到OPENEULER_REPO_NAMES中，如下：

 .. code::
    
    OPENEULER_REPO_NAMES = "src-kernel-${PV} kernel-${PV}"

 - CACHE_SRC_DIR: 上游源码缓存路径，这里指的缓存是存在一份全量的openEuler Embedded上游源码，如果设置了该值，那么在执行代码下载之前会优先从该缓存目录同步相应的代码仓。

整体openeuler_fetch下载就是依靠以上相关变量确定下载的包信息，而获取下载包的信息是在openEuler Embedded的基线文件中记录的，该文件目录为.oebuild/manifest.yaml，如果在基线文件中能命中该包信息，则会进行下载，否则不做任何操作。基线文件中的包信息包含该包的version，因此在命中该包后会根据version来确定该包的版本，并且为了更快的完成下载任务，我们尽可能的减少下载的代码量，因此openeuler_fetch在下载代码时其深度设定为1。在对该包的匹配过程中，如果本地可以检出该包的version，则直接切换包版本，否则进行fetch操作，然后再进行包版本检出。

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

可以看到其key键是pcre2，那么这种情况是因为其bbappend文件中设置了OPENEULER_LOCAL_NAME，关于这两个变量的使用请参考上文“openeuler_fetch运行机制”，这里不再详述，下面附上其代码范例：

.. code:: 

    # main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb

    # version in openeuler
    PV = "10.42"
    LIC_FILES_CHKSUM = "file://LICENCE;md5=41bfb977e4933c506588724ce69bf5d2"

    OPENEULER_REPO_NAME = "pcre2"

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
