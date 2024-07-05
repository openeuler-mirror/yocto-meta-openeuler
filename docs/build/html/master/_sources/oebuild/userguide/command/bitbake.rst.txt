.. _command_index_bitbake:

bitbake编译命令-bitbake
##################################

该命令用于根据构建配置文件来调起构建环境或直接执行编译操作，在oebuild中执行构建有两种模式，一种是交互模式，另一种是无人值守模式。交互模式是指oebuild将会准备好一切构建环境然后不再做下一步动作，接下来由用户自由的执行任意构建命令bitbake，无人值守模式即为用户直接执行目标构建操作，oebuild将以内部方式开始终端会话然后自行调起构建环境并自动执行目标构建操作。这两种模式适用场景有所不同，对于交互模式来说，主要面向的主体是人，交互模式可以扩展的功能相对较多，比如调试等。而无人值守模式面向的主体是机器，旨在应用oebuild实现构建不需要人为再次介入的场景。该命令参数相对来说比较简洁，使用范例如下：

- 交互模式命令：

  .. code-block:: console

      oebuild bitbake

  执行以上命令后即进入yocto构建的交互模式，此时看到的是一个新的会话终端，并会给出相应的欢迎语提示，如下：

  .. code-block:: console

      To run a command as administrator(user "root"),use "sudo <command>".

      Welcome to the openEuler Embedded build environment,
      where you can run bitbake openeuler-image to build
      standard images

      [openeuler@huawei-ThinkCentre-M920t-N000 hi3093]$ 

  此时直接使用bitbake命令执行构建目标操作即可，例如如下命令：

  .. code-block:: console

      # 执行关于busybox包的fetch任务
      [openeuler@huawei-ThinkCentre-M920t-N000 hi3093]$ bitbake busybox -c do_fetch

- 无人值守模式命令：

  .. code-block:: console

      oebuild bitbake busybox -c do_fetch

  该模式运行下将产生增量式日志。

  .. note:: 

      需要注意的是，oebuild每次在调起构建环境时，会自动在当前目录创建conf目录，该目录下包含local.conf和bblayers.conf两个配置文件，该两个文件是bitbake进行构件时必不可少的两个配置文件，前者是全局配置文件，后者是层解析配置文件，这两个文件的定制是会根据compile.yaml来修改的，但是如果已经产生了conf后再次修改compile.yaml，则不会再对conf有任何效果，如果想同步conf的内容，则在修改compile.yaml后同步删除conf，这样在检测到没有conf后oebuild会再次创建conf并同步修改相关配置文件。

- 容器内openeuler用户和用户组问题：

    oebuild bitbake功能会将宿主机端需要共享的问题进行权限变更，对应的容器端默认用户openeuler的uid和gid也会和宿主机保持一致，而/opt文件夹和/usr1文件夹在容器的操作权限在容器构建之时权限已经默认给了uid和gid为1000的用户。而宿主机的uid和gid如果不是1000的话，会导致/opt和/usr1没有权限，故出现此类问题只需要将这两个文件夹的操作权限变更到对应openeuler用户下即可。

- 容器启动卷挂载：

    oebuild bitbake在运行于容器构建时是会将源码目录和编译目录挂载到容器中的，具体的挂载详情可以参考编译目录下的compile.yaml，这里做个举例说明：

    .. code-block:: console

        docker_param:
            image: 
                swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
            parameters: -itd --network host
            volumns:
            - /dev/net/tun:/dev/net/tun
            - <path_to_oebuild_work>/src:/usr1/openeuler/src
            - <path_to_oebuild_work>/build/qemu-aarch64:/home/openeuler/build/qemu-aarch64
            command: bash

    这里主要查看volumns参数，从范例中来看，做了三个目录的挂载，tun目录这里不做说明，主要看源码目录src与编译目录qemu-aarch64。由于构建主要涉及到源码与编译目录，因此在容器启动时会对源码目录与编译目录映射到容器中，映射路径分别是/usr1/openeuler/src与/home/openeuler/build/<build_dir>，如果用户有特定的挂载需求，可以自行添加，但需要注意映射目录是否合适。
