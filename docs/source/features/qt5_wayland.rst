.. _qt5_wayland:

==================
嵌入式图形支持
==================

Wayland 是一个新一代的图形显示服务器协议，旨在替代 X Window System，提供更好的性能、更简单的代码和更好的安全性。

Weston 是一个开源项目，作为 Wayland 显示服务器协议的参考实现，它提供了一个基础的窗口管理系统，用于现代 Linux 桌面环境。Weston 基于 OpenGL ES 进行图形渲染，从而能够利用硬件加速功能来呈现流畅的图形界面。然而，Weston 本身并不构成一个完整的桌面环境，它更多地是一个构建块，用于与其他软件组件（如应用程序启动器、通知系统等）集成，以共同构建出一个完整的桌面体验。因此，Weston 在 Wayland 生态系统中扮演着重要的角色，为开发者提供了一个灵活的框架来构建现代化的、高效的桌面环境。

Qt5 是常见的嵌入式图形库之一，是一个跨平台的 C++ 应用程序开发框架，提供了丰富的图形界面组件和工具，可以用于开发桌面应用程序、嵌入式应用程序等；QtWayland 是 Qt5 框架中的一个模块，用于支持 Wayland 协议，QtWayland 模块提供了一组 API，使 Qt5 应用程序能够与 Wayland 协议兼容的显示服务器进行交互。

OpenEuler Embedded 系统支持使用 weston 作为窗口管理器，支持 Qt5 作为嵌入式图形库。


Wayland 框架简介
=========================


.. figure:: ../../image/qt/wayland_frame.png
    :align: center

    Wayland 框架示意图


部分模块介绍：

| **KMS/DRM：** 用于管理显示器与显卡；
| **evdev：** 输入设备驱动程序，可以处理各种输入设备，如键盘、鼠标、触摸屏等；
| **libinput：** 开源输入设备处理库，主要用于处理输入设备事件；
| **OpenGL：** Open Graphics Library，跨平台的图形库，用于渲染2D和3D图形；
| **Mesa：** 开源图形库，实现了OpenGL API的大部分功能，并且可以在多种操作系统和硬件平台上运行；
| **Wayland：** 狭义上讲只是一种显示协议, 可以不依赖于任何具体的 CPU/GPU 架构, 但具体的显示功能是由 Wayland Compositor 的实现而定；


openEuler Embedded 图形栈主要组成包
=====================================

| **wayland：** 一个用于图形栈合成器（Compositor）与客户端对话的协议，也是该协议的 C 库实现；Compositor 是 wayland 的核心组件，负责管理显示器、窗口和输入设备等硬件资源，并将客户端的图形输出合成为最终的显示图像；客户端是 wayland 的应用程序，通过 Wayland 协议与 Compositor 进行通信，可以是任何类型的应用程序，例如浏览器、文本编辑器、游戏等；
| **weston：** Wayland Compositor 的参考实现；
| **qtbase：** 提供 Qt5 程序应用开发所需的基础功能，是 Qt5 应用开发的基础；
| **qtsensors：** 用于访问和管理传感器硬件；
| **qtwayland：** 封装了 wayland 功能的 Qt5 模块，分为 client 端与 server 端；客户端提供了运行 wayland 客户端 Qt5 程序的方法，服务端提供了 Qt5 Wayland Compositor 应用程序接口，后续可支持用户创建自己的 Compositor；
| **mesa：** OpenGL API 的免费实现；
| **libdrm：** 基础用户态操作 DRM 运行库；
| **libinput：** 转换 evdev 事件为 wayland 事件。


构建指南
=================

构建结合了 meta-openeuler、poky/meta、meta-raspberrypi、meta-qt5、meta-oe 等层，目前支持在树梅派、rk3568等平台构建，构建流程如下：

.. code-block:: console

    # 树梅派构建
    $ oebuild generate -p raspberrypi4-64 -f systemd -f openeuler-qt -f opengl -f wayland -d ras-qt
    # ok3568构建
    $ oebuild generate -p ok3568 -f systemd -f openeuler-qt -f opengl -f wayland -d ok3568-qt
    # ryd-3568构建
    $ oebuild generate -p ryd-3568 -f systemd -f openeuler-qt -f opengl -f wayland -d ryd-3568-qt

    # 进入交互构建终端
    $ oebuild bitbake

    # 执行构建
    $ bitbake openeuler-image
    # SDK 构建
    $ bitbake openeuler-image -c populate_sdk


.. note:: 

    目前 rk3568 平台对 Qt5 支持尚不完善，正在开发改进中！！！


示例
================

image 中集成了一些 demo 程序用于测试功能是否正常，如下：

==================== ===============================================================
程序名                  作用   
==================== ===============================================================
kmscube                测试驱动（kms/drm）功能，在普通窗口界面运行；
helloworld-gui         Qt5 helloworld 程序；
==================== ===============================================================

在openEuler Embedded系统中运行 demo 程序。

.. note:: 

    Qt5 程序运行时可以通过 ``--platform`` 选项来指定使用的平台插件，eglfs 与 wayland 是两种常见的平台插件。


普通窗口界面： 

.. code-block:: console

    # kmscube
    # helloworld-gui --platform eglfs
    # helloworld-gui --platform linuxfb


wayland 插件需要在 weston 界面支持：

.. code-block:: console

    # weston
    # helloworld-gui --platform wayland


.. figure:: ../../image/qt/weston.png
    :align: center

    ``weston`` 效果图


.. figure:: ../../image/qt/helloworld-gui_1.png
    :align: center

    ``helloworld-gui --platform wayland`` 效果图1


.. figure:: ../../image/qt/helloworld-gui_2.png
    :align: center

    ``helloworld-gui --platform wayland`` 效果图2


快速开发SDK
====================

安装SDK
---------------

以树莓派镜像SDK为例：

.. code-block:: console

    # 请将 sdk-dir 替换为您希望安装SDK的目标目录
    $ sh openeuler-glibc-x86_64-openeuler-image-cortexa72-raspberrypi4-64-toolchain-24.03-LTS.sh -y -d sdk-dir

.. note::

    由于Qt5 SDK包含主机工具，需进行重定位操作。为确保成功安装，安装目录的长度应不超过构建时设定的动态链接器长度限制，即不超过37个字母。


使用方法
----------------

1. **准备代码**

  以构建一个hello world程序为例，运行在openEuler Embedded根文件系统镜像中。

  创建一个 :file:`hello.cpp` 文件，源码如下：

  .. code-block:: cpp

      #include<QApplication>
      #include<QLabel>

      int main(int argc,char * argv[])
      {
          QApplication app(argc,argv);
          QLabel * label=new QLabel("<h2><i>Hello</i><font color=red>Qt!</font></h2>");
          label->show();
          return app.exec();
      }


  创建 :file:`hello.pro` 文件，和 :file:`hello.cpp` 放在同一个目录；也可先使用 `qmake` 命令自动生成基础 pro 文件，可能需要手动补充部分内容，详细步骤如下：

  .. code-block:: console

      $ mkdir hello
      $ cd hello
      # 编写源码文件如上
      $ vi hello.cpp
      # 生成 hello.pro 文件
      $ qmake -project
      # 补充头文件依赖
      $ echo "greaterThan(QT_MAJOR_VERSION, 4): QT += widgets" >> hello.pro


2. **编译生成二进制**

  进入 :file:`hello.cpp` 所在目录，使用工具链编译，命令如下：

  .. code-block:: console

      # 使用qmake生成 Makefile 文件
      $ mkdir build
      $ cd build
      $ qmake ../hello.pro
      $ make
      $ file hello
      hello: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-aarch64.so.1, BuildID[sha1]=32b523488d52d5beba18b01d02cea287604680a9, for GNU/Linux 5.10.0, with debug_info, not stripped

  把编译好的 Qt5 程序拷贝到 openEuler Embedded 系统的 :file:`/tmp/` 某个目录下（例如 :file:`/tmp/myfiles/` ）。如何拷贝可以参考前文所述共享文件系统场景。


3. **运行用户态程序**

  在 openEuler Embedded 系统中运行 Qt5 程序。

  .. code-block:: console

      # cd /tmp/myfiles/
      # ./hello --platform eglfs or wayland

  如运行成功，则会输出 ``Hello Qt!`` 。

.. note::

    meta-qt5 层已对 qtbase 进行了补丁更新，支持通过配置 `OE_QMAKE_QTCONF_PATH` 环境变量来指定 :file:`qt.conf` 文件的路径。
