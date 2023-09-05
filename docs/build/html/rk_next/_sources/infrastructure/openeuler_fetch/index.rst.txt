.. _openeuler_fetch:


通过openeuler_fetch使用openEuler软件包
==========================================

特性介绍
***************************

在openEuler Embedded构建镜像时，需要提前下载所有软件包，而openEuler Embedded由上百个软件包构成，完全下载耗时耗力。功能函数openeuler_fetch解决了该问题，它可以在openEuler Embedded构建镜像时，按需从上游源码包自动下载软件包。例如当你只想编译busybox这一个软件包，而不需要将其他软件包全部下载的时候，使用openeuler_fetch即可实现，你只需要初始化完环境即可进入编译环节。

openeuler_fetch运行机制
***************************

openeuler_fetch在classes/openeuler.bbclass中实现，函数名为do_openeuler_fetch，该函数在base_do_fetch:prepend中通过bb.build.exec_func()函数调用，即openeuler_fetch运行完还会继续执行do_fetch，这样做的原因是不管openeuler_fetch运行成功与否都可以让fetch继续补充，例如有一款软件包在gitee中不存在，或在配置中配置错误，或者源码目录有相关的改动导致openeuler_fetch运行失败，不用担心，do_fetch可以继续完成文件的查找。

openeuler_fetch运行逻辑
***************************

openeuler_fetch通过以下控制变量来完成相关包下载：

 - OPENEULER_GIT_URL:  远程仓库前缀，默认值为https://gitee.com/src-openeuler，该变量在.oebuild/local.conf.sample中设置，全局生效，也可以在bb或bbappend文件中设置使之局部生效

 - OPENEULER_BRANCH: 软件包分支，在下载软件包时会通过该变量指定分支名称，该变量在.oebuild/local.conf.sample中设置，全局生效，也可以在bb或bbappend文件中设置使之局部生效

 - OPENEULER_REPO_NAME: 软件包名，该名一般和构建包名一致，但在特殊情况下需要改动，例如构建libtool-cross时，构建包名为libtool-cross，因此默认OPENEULER_REPO_NAME为libtool-cross，但是依赖包路径是libtool，则需要将OPENEULER_REPO_NAME改为libtool

 - OPENEULER_LOCAL_NAME: 软件包本地名称，即软件包在本地路径名称，一般该变量如果不设置则在系统处理时默认和OPENEULER_REPO_NAME一样，该变量意在解决软件包名和本地存储路径不一致问题

 - OPENEULER_SRC_URI_REMOVE: SRC_URI过滤变量，设置该变量可以在bitbake执行fetch之前移除设定的相关uri文件路径，该变量通过前缀进行匹配，例如设定OPENEULER_SRC_URI_REMOVE="https git"，则openeuler_fetch在处理时遇到以https和git开头的uri则会去除

整体openeuler_fetch下载就是依靠以上相关变量完成，由以上变量最终组成git下载参数：

 - remote: 默认为https://gitee.com/src-openeuler/xxx，由OPENEULER_GIT_URL/OPENEULER_REPO_NAME组成
 
 - branch: 默认为OPENEULER_BRANCH

依据remote和branch，openeuler_fetch完成下载

openeuler_fetch 运行原理图如下：
    .. image:: ../../../image/infrastructure/openeuler_fetch_process.png

repo_init 运行原理图如下：
    .. image:: ../../../image/infrastructure/openeuler_fetch_repo_init.png

如何适配其他软件包
***************************

在构建openEuler Embedded时经常会引入其他相关包或修改非指定包版本，那么此时该如何做呢？从上文中已经得知openeuler_fetch依赖5个变量来进行下载，内核是例外，因此我们只需要关注这五个变量即可，接下来我们以busybox为例进行讲解：

- 如果想要某一个版本的busybox参与构建：在busybox的bbappend文件中设定OPENEULER_BRANCH值为相关版本即可

- 如果想要使用自有仓库的busybox参与构建：在busybox的bbappend文件中设定OPENEULER_GIT_URL为自有空间即可，注意：如果busybox已经下载在本地，则需要手动删除，然后再执行构建

- 如果需要其他代码仓的busybox参与构建，则修改OPENEULER_GIT_URL为其他平台仓域名即可，例如https://github.com/xxx

- 另外，当构建busybox时需要的依赖并不会是某一款特定包，即不能直接通过depends添加依赖，而仅仅是需要某个路径下的文件，此时需要在bbappend中添加do_fetch:prepend，在该函数中添加需要依赖的包，例如：

::


    python do_fetch:prepend() {
        repoList = [{
            "repo_name": "yocto-embedded-tools",
            "git_url": "https://gitee.com/openeuler",
            "branch": "master"
        },{
            "repo_name": "libboundscheck",
            "git_url": "https://gitee.com/openeuler",
            "branch": "openEuler-22.09"
        },{
            "repo_name": "dsoftbus_standard",
            "git_url": "https://gitee.com/openeuler",
            "branch": "v3.1"
        },{
            "repo_name": "embedded-ipc",
            "git_url": "https://gitee.com/openeuler",
            "branch": "master"
        }]

        d.setVar("PKG_REPO_LIST", repoList)

        dd.build.exec_func("do_openeuler_fetchs", d)
    }

通过repoList设置好需要依赖的包，包结构格式不可更改，PKG_REPO_LIST变量的设定是为在do_openeuler_fetchs中获取依赖的包列表，do_openeuler_fetchs将依次解析PKG_REPO_LIST，并调用do_openeuler_fetch完成相关包的下载。

- 如果想要下载的busybox包在本地用其他路径，比如busyboyy，则在busybox的bb文件或bbappend文件设定OPENEULER_LOCAL_NAME="busyboyy"，当clone busybox时本地路径会变成busyboyy。注意,如果本地已经有busybox，但是依然设置了OPENEULER_LOCAL_NAME，那么原本地仓将不会做任何操作，openeuler_fetch将直接新建一个busyboyy

- 如果在编译busybox中所依赖的某些文件不想要，想统一去除，则可以在bb文件或bbappend文件中设定OPENEULER_SRC_URI_REMOVE变量，比如busybox的SRC_URI中有https或git开头的文件路径，但是我们想自己下载而不需要系统默认设定的，则可以设置OPENEULER_SRC_URI_REMOVE="https git"，这样openeuler_fetch在处理时就会去除以https和git开头的文件

如何关闭openeuler_fetch功能
***************************

OPENEULER_FETCH有两种关闭方式：

1. 在meta-openeuler/conf/layer.conf中有一个全局变量OPENEULER_FETCH，该值默认为enable，即openeuler_fetch是开启状态，如果想要关闭openeuler_fetch，设置该值为disable即可。

2. 在oebuild执行generate指令时，将参数-df带上，也可以关闭openeuelr_fetch功能

另外 ``OPENEULER_FETCH`` 该值的作用域是全局的，我们在开发中可能会针对某一些包不需要运行openeuler_fetch，则可以在相关包的bb或bbappend中设定该值为disable
