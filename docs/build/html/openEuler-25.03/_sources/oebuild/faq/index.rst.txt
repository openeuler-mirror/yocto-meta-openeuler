常见问题
#########

如何升级yocto和容器
--------------------

oebuild升级yocto与容器很简单，只需要在oebuild工作目录下通过执行oebuild update命令即可，如果要升级yocto，则执行以下命令：

.. code:: console

    oebuild update yocto

如果要升级容器，请先确保主机系统安装了docker软件，并且给予了当前用户执行权限，然后执行以下命令：

.. code:: console

    oebuild update docker

如何定制docker启动选项
-----------------------

在oebuild编译目录下，一般会有compile.yaml编译文件，用vim或其他编辑器打开compile.yaml，在末尾可以看到如下配置信息：

.. code:: console

    docker_param:
        image: swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
        parameters: -itd --network host
        volumns:
        - /dev/net/tun:/dev/net/tun
        - /path/to/src:/usr1/openeuler/src
        - /path/to/build/xxx:/home/openeuler/build/xxx
        command: bash

其中image表示启动的容器镜像，parameters即为容器启动的选项参数，这里默认为"-itd --network host"，如果想要做其他定制，直接对该字段进行删改即可，volumns表示容器启动和主机的目录挂载映射，command表示容器启动后选用的命令解析器。

对compile.yaml修改完成后，请先执行`rm -f .env`命令，然后再启动`oebuild bitbake`命令，此时定制的容器启动参数才能生效，这是因为oebuild为了更加快速的响应启动环境，会复用已启用的容器，而.env文件则记录了正在使用的容器ID，如果对容器启动参数做了定制，则删除.env后，再次执行`oebuild bitbake`，oebuild会重新以当下compile.yaml的配置项来启动容器。
