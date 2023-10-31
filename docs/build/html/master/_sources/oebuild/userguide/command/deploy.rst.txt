.. _command_index_deploy:

部署命令-deploy
############################

该命令用于将openEuler镜像部署到指定平台。目前该功能处于试运行阶段。
该指令将编译或者下载的镜像文件，部署到指定平台的功能。目前仅支持qemu-system平台。
一键执行后，命令行将直接跳转到qemu用户登录界面。

命令的使用范例如下：

.. code-block:: console

    oebuild deploy [-p platform]

-p用来指定部署目标平台架构。

-p: platform
--------------

该参数用来指定部署的目标平台架构。可选项：arm, aarch64, riscv64, x86_64。此值默认为aarch64。该参数使用方式如下：

.. code-block:: console

    oebuild deploy -p aarch64
