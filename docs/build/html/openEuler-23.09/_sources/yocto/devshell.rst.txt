.. _yocto_terminal:

====================
Yocto 实现终端应用
====================

Yocto提供一个termianl类用于开启新终端，可实现终端应用。本章节介绍相关的一些应用。


terminal 类
=================

``terminal`` 类实现一些基本配置，为启动终端会话功能提供支持。

- **OE_TERMINAL：** 设置使用哪一个终端模拟器，默认是 ``OE_TERMINAL ?= 'auto'`` ，根据优先级自动选择；
- **OE_TERMINAL_EXPORTS：** 传到新终端环境中的变量；

构建环境中需要安装终端应用，用户可自由选择，如果同时安装了多个terminal命令，可配置OE_TERMINAL变量进行选择；以下介绍两个终端应用：

- **tmux：** 纯粹的命令行界面，不支持鼠标翻滚，优先级比screen高；
- **screen：** 支持鼠标翻滚，目前openEuler使用时 tab 键不太方便。

openEuler 最新容器中已安装screen应用。


devshell 类
================

继承自terminal类，yocto构建会默认继承此类。此类提供 ``do_devshell`` 任务，进入BitBake任务执行环境，环境中会配置好相关的变量，如CC、CFLAGS；

使用举例：

::

    bitbake -c devshell busybox 

会在当前终端新启一个终端，进入源码目录（${S}），可以在此终端进行开发操作，可以通过运行 :file:`${WORKDIR}/temp/run.do_*` 脚本来达到 ``bitbake -c task_name`` 相同的效果。 :file:`${WORKDIR}/temp/run.do_*` 脚本需要执行对应任务后才会生成，如果不存在对应脚本需要先执行bitbake命令生成，如 ``bitbake busybox -c configure``。使用 ``exit`` 指令退出。

.. note:: 

    进入新终端后不能运行bitbake，存在文件锁（bitbake.lock）。

此任务在 ``do_patch do_prepare_recipe_sysroot`` 任务之后执行。


cml1 类
===============

继承自terminal类， ``cml1`` 类为Linux内核风格的构建配置系统提供了基本支持。

- 提供 ``do_menuconfig`` 任务，会调用 ``make menuconfig`` 命令；
- 提供 ``do_diffconfig`` 任务，会比较新旧config文件并生成一个文件保存差异。

使用举例：

::

    bitbake -c menuconfig busybox
    bitbake -c diffconfig busybox
