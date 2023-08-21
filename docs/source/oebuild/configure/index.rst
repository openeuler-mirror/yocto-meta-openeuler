.. _configure_index:

配置文件介绍
########################

这一章节将会对openEuler Embedded所有涉及到的配置文件进行详细的讲解说明，这些说明包括每个参数的意义，以及该参数的影响范围

config：全局配置文件
--------------------

全局配置文件内容如下：

::

    docker:
        repo_url: swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container
        tag_map:
            openEuler-23.03: "23.03"
            master: latest
            openEuler-22.03-LTS-SP2: 22.03-lts-sp2
    basic_repo:
        yocto_meta_openeuler:
            path: yocto-meta-openeuler
            remote_url: https://gitee.com/openeuler/yocto-meta-openeuler.git
            branch: master

从内容上看，全局配置文件主要分为两大类，一类是跟docker相关的，一类是跟基本repo相关的，下面将对这两类做详细的说明

docker
>>>>>>

docker下主要记录openEuler Embedded构建容器的镜像相关数据，这些数据可以用来进行对需要使用的容器是否合规提供判断的参考，repo_url表示容器远程下载地址，tag_map是openEuler Embedded的版本与构建容器镜像的版本的映射关系，而oebuild在使用容器端进行构建时会通过该tag_map信息识别出该启用哪个构建容器

.. note:: 在使用oebuild初始化工作目录后，该配置文件也同样会被创建出来，如果有openEuler Embedded新的版本，那么tag_map则不会有任何的更新，需要手动进行更新，直接将openEuler Embedded对应的版本与docker tag对应关系按照现有的规范以yaml格式追加到tag_map下面即可。

basic_repo
>>>>>>>>>>

basic_repo主要记录的是构建openEuler Embedded的根仓，所谓的根仓就是构建openEuler Embedded一切源码的最初来源，通过该仓可以将所有相关的依赖都解析出来，在这里openEuler Embedded的根仓也就是源码仓就是yocto-meta-openeuler，使用的是git模式下的相关信息，path表示在src目录下的目录命名，remote_url表示上游地址，branch表示分支名。在oebuild执行 `update yocto` 操作时会根据该basic_repo信息来进行更新。

.. note:: 需要注意的是，如果现有的yocto-meta-openeuler分支版本与basic_repo下记录的不一致，在更新时将会将现有yocto-meta-openeuler进行备份，备份目录为oebuild根目录下的bak目录

compile.yaml.sample：构建配置模板文件
-------------------------------------

构建配置模板文件与构建配置文件是同一个类型文件，其内容如下：

::

    # compile.yaml is the build configuration file of the build tool oebuild under 
    # openEuler Embedded, which will parse the file when executing the oebuild bitbake, 
    # and by parsing the file, the built image will be set in various ways, and the 
    # most critical is still the modification of local.conf and bblayers.conf. Not all 
    # parameters need to be set here, mainly around whether the build environment is in 
    # the container, that is, some parameters are valid in the container and some are 
    # valid in the host environment. The build configuration file is a demo file, you can 
    # remove the file name suffix .sample, and then customize or configure it according to 
    # your needs, and then execute `oebuild bitbake -f <compile_dir> [target]` to build 
    # according to the specified build configuration file


    # build_in can specify the environment used to build,
    # and currently we have two environments, one is built in a
    # container and the other is built on the host. The list of
    # parameters for both environments is as follows:
    # 1, docker
    # 2, host
    # but, default param is docker
    build_in: docker


    # docker_image specifies the container image when building in the container
    #
    docker_image: swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest


    # platform specifies the board at build time, if it is not 
    # clear what the value of the board is, it can be determined by 
    # executing `oebuild generate -l platform`, this command will list 
    # all supported boards for openEuler Embedded
    #
    platform: aarch64-std


    # mechine replaces the mechine parameter in local.conf, 
    # in general, platform lists a list in the 
    # `yocto-meta-openeuler/.oebuild/platform` directory, and the 
    # mechine value is specified in the specific platform
    #
    mechine: qemu-aarch64


    # toolchain_type specifies the identity of the external toolchain, 
    # if the build environment is in a container, you need to locate 
    # the cross-compilation chain address through this identity, and 
    # the list of cross-compilation chain address mappings in the 
    # container is as follows:
    # 1，EXTERNAL_TOOLCHAIN_arm = "/usr1/openeuler/gcc/openeuler_gcc_arm32le"
    # 2，EXTERNAL_TOOLCHAIN_aarch64 = "/usr1/openeuler/gcc/openeuler_gcc_arm64le"
    # 3，EXTERNAL_TOOLCHAIN_x86-64 = "/usr1/openeuler/gcc/openeuler_gcc_x86_64"
    # 4，EXTERNAL_TOOLCHAIN_riscv64 = "/usr1/openeuler/gcc/openeuler_gcc_riscv64"
    #
    toolchain_type: EXTERNAL_TOOLCHAIN_aarch64

    # toolchain_dir specify the cross-compilation chain directory 
    # used at build time, if the build environment is in a container, 
    # that is, build_in parameter is docker, this parameter does not 
    # need to be specified, because the cross-compilation chain is 
    # already built in the container, if the build environment is in 
    # the host, that is, the build_in parameter is host, this parameter 
    # needs to be specified. There are currently 4 cross-compilation chains, 
    # and the list of paths in the container build environment is as follows:
    # 1, /usr1/openeuler/gcc/openeuler_gcc_arm64le
    # 2, /usr1/openeuler/gcc/openeuler_gcc_arm32le
    # 3, /usr1/openeuler/gcc/openeuler_gcc_x86_64
    # 4, /usr1/openeuler/gcc/openeuler_gcc_riscv64
    #
    # toolchain_dir: /usr1/openeuler/gcc/openeuler_gcc_arm64le


    # nativesdk_dir represents the compiled SDK directory, nativesdk hosts 
    # some external tools and dynamic link libraries needed at build time, 
    # etc., these things will not be packaged into the image, the same as 
    # the toolchain_dir parameters, if the build environment is in the 
    # container, do not need to be specified, the container has been built-in, 
    # if the build environment is in the host, you need to specify the directory.
    #
    # nativesdk_dir: /opt/buildtools/nativesdk


    # not_use_repos specifies whether to update the layer layer when starting
    # the build environment, it needs to be updated by default, if you debug or 
    # modify the layer layer, you can set this parameter to true.
    #
    # not_use_repos: false


    # sstate_cache specifies whether the sstate-cache mechanism is used when 
    # yocto is built, and if so, the SSTATE_MIRRORS value in local.conf will be 
    # modified, and there are two SSTATE_MIRRORS values, one is a remote link, 
    # and the other is a local directory, both pointing to the directory of specific 
    # sstate-cache. There are two types of values for SSTATE_MIRRORS:
    # 1，file://.* http://someserver.tld/share/sstate/PATH;downloadfilename=PATH
    # 2，file://.* file:///some/local/dir/sstate/PATH
    # If you set this parameter to http://xxxx/share, eventually in local.conf, 
    # the SSTATE_MIRRORS will be set to 
    # file://.* http://xxxx/share/PATH;downloadfilename=PATH, and if the cost path 
    # is set, the SSTATE_MIRRORS will be set to file:// .* file://xxx/PATH. 
    # Another thing to note is that if the build environment is in a container, 
    # specifying the sstate-cache path will be mounted to the 
    # /usr1/openeuler/sstate-cache directory in the container when the container 
    # is created, so the value of the SSTATE_MIRRORS in local.conf will become 
    # file://.* file:///usr1/openeuler/sstate-cache/PATH
    #
    # sstate_cache: xxx


    # sstate_dir specifies the path where yocto stores sstate at build time, 
    # this variable corresponds to the SSTATE_DIR in local.conf, and this variable 
    # is only useful if the build environment is the host environment
    #
    # sstate_dir: xxx


    # tmp_dir specifies the path to the tmp directory in Yocto, which is used 
    # to store Yocto's build output, corresponding to the TMP_DIR parameter in 
    # local.conf. Also, this parameter is only valid if the build environment 
    # is a host environment
    #
    # tmp_dir: xxx

    # repos is used to set the code repository required to initialize the build 
    # environment when openEuler Embedded is built, usually the following parameter 
    # should list the information of the layers layer required by bitbake during 
    # initialization, which can be set according to your own needs. The following 
    # values of this parameter have format requirements, which are illustrated here:
    # repos:
    #    abc:
    #      url: xxxxxxxxxxx
    #      path: xxxxxxxxxx
    #      refspec: xxxxxxxxxxxx
    # the key abc represents a repository, url is remote url, path is local path, it means
    # when download repository，it will be stored in local, in general, the key abc is same 
    # to path, refspec is point branch or tag
    #
    # repos:
    #   abc:
    #     url: xxxx
    #     path: xxxx
    #     refspec: xxx

    # local_conf is to supplement the setting of various parameters in local.conf, and all 
    # values filled in under this variable will be appended to local.conf unchanged
    #
    # local_conf:
    #   xxx

    # The layers parameter specifies the layer of bitbake at initialization, the value of 
    # this parameter is a relative value, that is, the path under the src directory, for example, 
    # set a layer of layers to yocto-meta-openembedded/meta-python, it will eventually be replaced 
    # with /<build_dir>src/yocto-meta-openembedded/meta-python in layers
    # 
    # layers:
    #   xxxx

下面针对每个参数进行说明：

build_in
>>>>>>>>

构建模式选择，目前oebuild对openEuler Embedded的构建有两种模式，主机端模式和容器端模式，分别用docker和host来表示，该参数是必须项，设置方式如下：

.. code-block:: console

    # 设置容器端构建
    build_in: docker

    # 设置主机端构建
    build_in: host

docker_image
>>>>>>>>>>>>

构建容器镜像，在使用容器端构建时该字段表示该次构建将会启用的容器镜像版本，该字段非必须项，主机端构建该参数不需要设置，设置方式如下：

.. code-block:: console

    docker_image: xxxxxxxxxxx

platform
>>>>>>>>

目标架构平台，这里用于设置构建openEuler Embedded时的单板名称，该名称来源于 `yocto-meta-openeuler/.oebuild/platform` 的列表，设置方式如下：

.. code-block:: console

    platform: aarch64-std

machine
>>>>>>>

运行机器名称，该名称是由在单板配置文件下的machine字段确定的，在yocto中，machine参数是指目标设备的硬件架构和配置，在代码层面会直接以该名称指定这个machine的配置文件名，在该配置文件下有对该单板的一系列设置。设置方式如下：

.. code-block:: console

    machine: qemu-aarch64

toolchain_type
>>>>>>>>>>>>>>

外部编译链名称，通过该值可以获取默认设定好的编译链地址，这个在yocto构建过程中需要指定交叉编译链二进制地址时需要指定的，目前已适配的CPU架构有四个：aarch64，arm32，x86_64和riscv64。设置方式如下：

.. code-block:: console

    # openEuler Embedded-22.03-LTS-SP2及其之前版本
    toolchain_type: EXTERNAL_TOOLCHAIN_aarch64
    # openEuler Embedded-22.03-LTS-SP2之后版本
    toolchain_type: EXTERNAL_TOOLCHAIN:aarch64

.. note:: 设置的方式不一致原因是选定的poky版本不同导致的，在openEuler-22.03-LTS-SP2及其之前选用的poky版本为3.3，而在其之后选用的poky版本为4.0，3.3版本与4.0版本对于变量集的命名语法不同，因此toolchain_type的设置方式有所区别

toolchain_dir
>>>>>>>>>>>>>

外部编译链路径，在设置外部编译链类型后，如果对编译链路径做了设置，那么oebuild会对编译链类型指向的默认编译链地址进行相应的替换，将原默认的编译链地址替换成设置好的地址，如果是容器端构建模式，那么地址的映射为 `/host/external_toochain_dir:/usr1/openeuler/native_gcc` ，如果是主机端构建模式，则直接将设置好的地址进行替换。设置方式如下：

.. code-block:: console

    toolchain_dir: /host/external/toolchain_dir

nativesdk_dir
>>>>>>>>>>>>>

构建工具路径，openEuler Embedded在构建过程中是需要一些中间辅助工具的，这些辅助工具可以直接通过poky相应版本来自行编译得到，也可以直接从openEuler Embedded相应的指定地方下载。设置方式如下：

.. code-block:: console

    nativesdk_dir: /host/nativesdk

.. note:: 需要注意的是，该参数的设定只有在主机端构建模式下才有效，如果是容器端构建因为容器端已经有内置的nativesdk_dir，则不会做任何操作

not_use_repos
>>>>>>>>>>>>>

是否更新layer仓选项，该参数影响范围较小，openEuler Embedded的构建依赖的源码包版本是从基线文件manifest.yaml中获取到的，如果想要在构建时不再选用稳定上游软件包版本而直接使用选定分支最新代码，则可以通过将manifest移除来实现，那么在下载上游源码包时会从openeuler默认指定的版本来下载，但是layer层并不属于上游软件包，因此会直接通过compile.yaml中的repos下的信息来进行更新，然而面对用户不需要layer层的更新则可以设置该字段实现，默认该参数为false。设置方式如下：

.. code-block:: console

    not_use_repos: true

sstate_cache
>>>>>>>>>>>>

sstate-cache的镜像地址，在yocto构架框架下，sstate-cache是一个很好的缓存机制，可以大大减少重复构建的行为，节省构建时间，通过该参数设置缓存路径可以在构建时命中构建依赖产物从而减少构建任务。设置方式如下：

.. code-block:: console

    # 使用本地站点类型
    sstate_cache: /some/where/sstate_cache

    # 使用web站点类型
    sstate_cache: http://some.website/sstate_cache

sstate_dir
>>>>>>>>>>

sstate-cache存放路径，在yocto构建过程中，会实时产生sstate-cache，默认会存放在构建根目录下的sstate-cache目录，如果进行指定则会存放在指定的目录，需要注意的是，该值在主机端构建时设置才有效。设置方式如下：

.. code-block:: console

    sstate_dir: /some/where/sstate_dir

tmp_dir
>>>>>>>

临时文件存放目录，在yocto构建过程中会有大量的临时文件产生，默认会存放在构建根目录下的tmp_dir目录，如果进行指定则会存放在指定的目录，需要注意的是，该值在主机端构建时设置才有效。设置方式如下：

.. code-block:: console

    tmp_dir: /some/where/tmp_dir

repos
>>>>>

启动构建所需要的layer层所在的代码仓列表。yocto的构建会在设置的bblayers层下解析所有的bb或bbappend文件，在openEuler Embedded中，yocto-meta-openeuler是主构建仓，所有的依赖软件包是以bbappend追加文件的方式进行的定制，而对于组成openEuler Embedded的所有软件包的bb文件主要存放在几个特定的layer仓中，主构建仓下所有的bb或bbappend会被解析，但是在yocto中，bbappend是必须要有bb文件为载体的，否则会解析错误，而对于基本的标准openEuler Embedded来说，包含的软件包主要来自两个上游层，yocto-poky与yocto-meta-openembedded，因此我们可以看到，这两个层都会被设置在bblayers中。如果进行构建openEuler Embedded，所需要的layer层是必须要存在的，因此该参数是用来设置这些必须的层信息，在yocto正式开始解析之前会提前下载好。如果有其他特性的加入，则可以在该参数下加入上游层，该参数设置方式如下：

.. code-block:: console

    repo:
        abc: 
            url: xxx
            path: xxx
            refspec: xxx

abc表示包名，url表示远程仓地址，path表示下载到本地的文件目录名，refspec表示版本信息

local_conf
>>>>>>>>>>

local.conf文件补充内容。在yocto构建当中，会有两个必须的配置文件，其中一个就是local.conf，local.conf文件中的选项可以覆盖yocto默认的配置选项。这些选项包括构建目标，构建工具链，构建方式，构建环境变量，构建输出路径等。通过修改local.conf文件，可以定制化构建系统，以满足特定的需求。例如，可以通过设置MACHAINE选项来指定目标硬件平台，通过设置DISTRO选项来选择使用哪个Linux发行版作为基础系统，通过设置PACKAGE_CLASSES选项来选择使用哪种软件包格式等等。local_conf是对默认local.conf的内容补充，如果有特定的设置，则可以在该参数下添加。该参数设置方式如下：

.. code-block:: console

    local_conf: |
        xxxx
        xxxx

layers
>>>>>>

bblayers.conf文件补充内容。在yocto构建当中，会有两个必须的配置文件，其中一个就是bblayers.conf，bblayers.conf文件用于指定yocto构建系统中使用的层（layers）的位置和顺序。每个层都包含了一些元数据，例如：软件包，配置文件，脚本等等。bblayers.conf文件告诉yocto构建系统在哪里可以找到这些层，以及他们的顺序。具体来说，bblayers.conf文件包含以下信息：BBLAYERS变量，定义了一个层的列表，每个层都是一个目录的路径。这些层的顺序非常重要，因为它们会影响构建系统中软件包的优先级和覆盖顺序。BBPATH变量，该变量定义了构建系统中所有层的路径，它是BBLAYERS变量中的层路径组成的，以冒号分隔。而layers的设置是对BBLAYERS内容的补充。该参数设置方式如下：

.. code-block:: console

    layers: xxxx

.env：构建运行环境文件
----------------------

该文件用于记录在构建时所运行的环境的一些参数，文件内容如下：

:: 

    container:
        remote: https://gitee.com/alichinese/yocto-meta-openeuler.git
        branch: refactor
        short_id: 6ce6bd486f1e
        volumns:
        - /home/huawei/桌面/demo/src:/usr1/openeuler/src
        - /home/huawei/桌面/demo/build:/home/openeuler/build

container
>>>>>>>>>

容器相关运行时参数，在oebuild使用容器端构建时会将启动的容器相关参数记录下来

remote
::::::

当前yocto-meta-openeuler仓的远程地址

branch
::::::

当前yocto-meta-openeuler仓的远程仓分支名

short_id
::::::::

本次构建启动的容器ID

volumns
:::::::

容器启动后的挂载目录列表
