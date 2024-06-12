.. _new_develop:

开发方式指导
#####################

代码开发可以分为基于SDK的开发以及基于yocto的开发，下面分别进行详细解释


基于SDK的开发方式
=========================

该开发方式在 :ref:`getting_started` 中 **基于SDK的应用开发** 章节有详细介绍

____


基于yocto的开发方式
=============================

openEuler Embedded提供了基于yocto工程的开发方式，开发者可以依赖yocto构建工程中的编译器、库、头文件等进行开发。
不同于SDK开发方式，yocto构建工程不需要手动设置编译器等，适用于添加软件包开发的场景。
若只需单独编译用户态程序或内核，建议采用基于SDK的开发方式。
下面将介绍如何使用ARM64的yocto构建工程进行开发。

1. 搭建yocto构建环境
----------------------

   按照 :ref:`getting_started` 指导搭建ARM64构建环境，完成必要主机包安装以及oebuild构建环境初始化后，
   构建容器会被拉取到本地，此时在 ``<work_dir>`` 执行以下命令即可进入构建容器的环境：

   .. code-block:: shell

      cd <work_dir>

      # 下载yocto-meta-openeuler以及构建使用的容器
      oebuild update

      # 下载源码，便于后续基于yocto的开发
      oebuild manifest download -f src/yocto-meta-openeuler/.oebuild/manifest.yaml

   构建环境生成后即可开始进行软件包/内核开发

2. 添加软件目录及代码
--------------------------------

  1. **通过本地添加软件目录及代码**

     以添加hello软件包（功能为打印hello world）为例，运行在openEuler Embedded根文件系统镜像中。

     在src目录下创建一个hello目录，其中包含 :file:`hello.c` 文件，源码如下：

     .. code-block:: c

        #include <stdio.h>

        int main(void)
        {
            printf("hello world\n");
        }

     编写CMakeLists.txt，和hello.c文件放在同一个目录。

     .. code-block:: CMake

        project(hello C)

        add_executable(hello hello.c)

  2. **通过yaml添加软件目录及代码**

     在 gitee 或其他线上托管仓库上建立 hello 仓库，仓库中添加如上的hello.c及CMakeLists.txt文件，
     将仓库地址添加至 yaml 文件 :file:`yocto-meta-openeuler/.oebuild/manifest.yaml` 末尾：

     .. code-block:: console

         hello:
            remote_url: https://gitee.com/openeuler/hello.git
            version: 4da472bba5924d1d422b595ae7497935ee678de0

3. 添加BB文件
--------------------------------
     添加完软件目录后，在yocto仓库中添加 hello 仓库的编译配方，配方添加方式参考 :ref:`yocto_development`
     将BB文件添加至 ``yocto-meta-openeuler/meta-openeuler/recipes-core/hello`` 目录中
     BB文件参考如下：

     .. code-block:: console

        S = "${WORKDIR}/git"
        SRCREV = "4da472bba5924d1d422b595ae7497935ee678de0"

        inherit  packagegroups

        PACKAGES =+ "hello"

        FILES:hello = "hello"

        do_install:append() {
            install -D -m 0755 ${WORKDIR}/hello ${D}/sbin/hello
        }

4. 添加编译项并编译全量镜像
--------------------------------

     以 qemu-aarch64 镜像为例，在其编译配置中添加 hello 包的编译项
     路径为 ``yocto-meta-openeuler/meta-openeuler/recipes-core/packagegroups/packagegroup-core-base-utils.bb``
     在编译包的最后添加hello包编译

     .. code-block:: console

        RDEPENDS:${PN} = "\
        audit \
        auditd \
        audispd-plugins \
        cracklib \
        libpwquality \
        libpam \
        packagegroup-pam-plugins \
        shadow \
        shadow-securetty \
        bash \
        hello \
        "


     进入yocto编译环境, 命令如下：

     .. code-block:: console

        $ oebuild generate -p qemu-aarch64 -d build_arm64
        $ oebuild bitbake
        $ bitbake openeuler-image

     把编译好的镜像和文件系统通过qemu启动。

5. 运行软件
--------------------------------

    **运行用户态程序**

        在openEuler Embedded系统中运行hello程序。

        .. code-block:: console

            $ hello

        如运行成功，则会输出 ``hello world``。
