.. _install_index:

安装介绍
########################

该文档讲解如何安装oebuild，并使能oebuild。

如何安装
========

oebuild是用python语言编写，并且适配的python版本为python3，目前oebuild已经在PyPi平台发布。因此可以通过pip3命令进行安装或升级oebuild。由于openEuler Embedded的构建目前仅适配常用的x86架构，因此对于其他架构的底层硬件，并不适用，同时对于x86架构的上层系统，仅支持linux和macOS。

On Linux:

.. code-block:: console

    pip3 install --user -U oebuild

On macOS:

.. code-block:: console

    pip3 install -U oebuild

在安装oebuild后，就可以使用oebuild来下载openEuler Embedded相关源码了。

.. note:: 目前oebuild支持的最低的python3版本为python3.8


环境依赖安装
============

oebuild的构建有两种方式：分别是主机端构建和容器端构建

**何为主机端构建**：

主机端构建即为直接使用主机环境进行构建，构建所需要的编译链和构建依赖工具需要在主机端进行初始化并加入到环境变量中，在构建过程中，可以直接使用主机端初始化的编译链和构建依赖工具，使用主机端构建有可能会破坏本地默认的环境配置，因此不建议使用。

**何为容器端构建**：

容器端构建即为使用容器进行构建，构建所需要的编译链和构建依赖工具已经被提前内置到特定的容器中，在oebuild启动容器后会自动完成环境变量的初始化动作，然后进入构建目录，可以直接执行yocto的构建。

**如何安装docker依赖**：

Docker容器对linux内核新功能的要求比较高，所以使用Ubuntu作为Docker容器的宿主机更加友好一点。而且很多项目Docker在配置的时候也仅仅支持了针对Ubuntu的dockerfile配置，所以容器化方面Ubuntu比较有优势。因此这里建议使用ubuntu作为开发平台。

ubuntu安装Docker命令如下：

.. code-block:: console

    sudo apt install docker.io

在安装好docker后，由于oebuild在调用docker时会以当前用户来进行调用，因此需要将当前用户添加docker执行权限，按如下方法完成给当前用户添加docker执行权限：

- 添加docker用户组

.. code-block:: console
    
    sudo groupadd docker

- 将当前用户添加到docker用户组

.. code-block:: console

    sudo usermod -a -G docker <user>

- 重新启动docker服务

.. code-block:: console

    sudo systemctl daemon-reload

    sudo systemctl restart docker

- 向docker套接字添加读写权限

.. code-block:: console

    sudo chmod o+rw /var/run/docker.sock

.. note:: 
    
    docker由client和server组成，docker的任何终端命令输入，实际上是通过客户端将请求发送到docker的守护进程 `docker daemon` 服务上，由 `docker daemon` 返回信息，客户端收到信息后展示在控制台上。
    而 `/var/run/docker.sock` 是 `docker daemon` 监听的套接字socket(ip+port)，容器中的进程可以通过它与 `docker daemon` 通信，对于docker的交互，可以使用官方给出的二进制cli，即docker，也可以使用实现了 `docker apis` 的client，例如python-docker，在这里由于oebuild对于docker的处理需要用到对 `/var/run/docker.sock` 的操作，因此需要对该套接字添加执行权限。
