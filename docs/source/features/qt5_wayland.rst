嵌入式图形支持
****************

特性介绍
###############

**Qt5+Wayland 框架简介**

  图形栈框架：

  .. figure:: ../../image/qt/wayland_frame.png
      :align: center

|  Qt5: GUI 库，用于开发图形界面应用程序;
|  Wayland: 狭义上讲只是一种显示协议, 可以不依赖于任何具体的 CPU/GPU 架构, 但具体的显示功能是由 Wayland Compositor 的实现而定。
|  OpenGL: Open Graphics Library，开放式图形库；
|  KMS/DRM：底层图形显示驱动。

**openEuler Embedded 图形栈主要包**

|  wayland: 一个用于合成器（compositor）与客户端对话的协议，也是该协议的C库实现；合成器可以是运行在 Linux 内核模式设置和 evdev 输入设备上的独立显示服务器。客户端可以是传统应用程序、X服务器（无根或全屏）或其他显示服务器；
|  weston: wayland 合成器的参考实现；
|  qtwayland: 封装了 wayland 功能的 Qt5 模块，分为 client 与 server 端；客户端提供了运行 wayland 客户端 Qt 程序的方法，服务端提供了 Qt Wayland Compositor 应用程序接口，用户可用于创建自己的合成器(未实现)；
|  mesa：OpenGL API 的免费实现(一个用于渲染交互式3D图形的系统)；mesa EGL 和 mesa vulkan 栈支持 wayland，许多 wayland 应用程序，都依赖于 EGL Wayland 平台；
|  libdrm：基础用户态操作 DRM 运行库；
|  libinput：转换 evdev 事件为 wayland 事件。

构建指南
###########

构建兼容了 meta-openeuler、poky/meta、meta-raspberrypi、meta-qt5、meta-openembedded 等层，目前只支持 systemd 的启动方式，支持在树梅派、rk3568平台构建，构建流程如下：

.. code-block:: console

    # 树梅派构建
    $ oebuild -p raspberrypi4-64 -f systemd -f openeuler-qt -d ras-qt
    # ok3568构建
    $ oebuild -p ok3568 -f systemd -f openeuler-qt -d ok3568-qt
    # ryd-3568构建
    $ oebuild -p ryd-3568 -f systemd -f openeuler-qt -d ryd-3568-qt

    # 进入交互构建终端
    $ oebuild bitbake

    # 执行构建
    $ bitbake openeuler-image
    # sdk构建
    $ bitbake openeuler-image -c populate_sdk


使用方法
#############

image 中集成了一些 demo 程序用于测试功能是否正常，如下：

==================== ===============================================================
程序名                  作用   
==================== ===============================================================
kmscube                测试驱动（kms/drm）功能，在普通窗口界面运行；
qt5-opengles2-test     测试 Qt5 OpenGL ES 2.0渲染；
helloworld-gui         Qt5 helloworld 程序；
==================== ===============================================================

在openEuler Embedded系统中运行 demo 程序。
  
普通窗口界面： 

.. code-block:: console

    # kmscube
    # qt5-opengles2-test --platform eglfs

weston 窗口界面：

.. code-block:: console

    # qt5-opengles2-test --platform wayland
    # helloworld-gui --platform wayland-egl

qt5-opengles2-test --platform eglfs 执行效果图：

.. figure:: ../../image/qt/qt5-opengles2-test.png
    :align: center

weston 执行效果图：

.. figure:: ../../image/qt/weston.png
    :align: center

helloworld-gui --platform wayland 执行效果图：

.. figure:: ../../image/qt/helloworld-gui_1.png
    
.. figure:: ../../image/qt/helloworld-gui_2.png
    :align: center


SDK 编译 qt 程序样例
######################

1. **准备代码**

  qmake 运行时以硬编码的方式加入库路径，意味着 qmake 一旦生成很多变量就写死了，需要编写 qt.conf 文件放在 qmake 二进制的同级目录。

  编写 :file:`qt.conf` 文件，源码如下：

  .. code-block:: console

      [Paths]
      prefix = xxx/sysroots/cortexa72-openeuler-linux
      Headers = xxx/sysroots/cortexa72-openeuler-linux/usr/include
      Libraries = xxx/sysroots/cortexa72-openeuler-linux/usr/lib64
      HostData = xxx/sysroots/cortexa72-openeuler-linux/usr/lib64
      Sysroot = xxx/sysroots/cortexa72-openeuler-linux
      TargetSpec = linux-oe-g++

  xxx 表示 SDK 所在目录的前缀。

  可通过 :file:`qt.conf` 设置 Binaries 字节来配置二进制所在路径，如 qttools 二进制所在路径为 /usr/lib/qt5/bin/，则 :file:`qt.conf` 新增如下行：

  .. code-block:: console

      Binaries = /usr/lib/qt5/bin
      HostBinaries = /usr/lib/qt5/bin

  编写 :file:`hello.cpp` 文件，源码如下：

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

  编写 :file:`hello.pro`，和 :file:`hello.cpp` 文件放在同一个目录；也可使用 qmake 命令自动生成 pro 文件，但需要手动补充部分内容，示例：

  .. code-block:: console

      $ qmake -project

2. **编译生成二进制**

  进入 :file:`hello.cpp` 所在目录，使用SDK编译，命令如下：

  .. code-block:: console

      $ qmake hello.pro
      $ make

  把编译好的 qt 程序拷贝到 openEuler Embedded 系统的 :file:`/tmp/` 某个目录下（例如 :file:`/tmp/myfiles/` ）。如何拷贝可以参考前文所述共享文件系统场景。

3. **运行用户态程序**

  在 openEuler Embedded 系统中运行 qt 程序。

  .. code-block:: console

      # cd /tmp/myfiles/
      # ./hello --platform eglfs or wayland

  如运行成功，则会输出"Hello Qt!"。
