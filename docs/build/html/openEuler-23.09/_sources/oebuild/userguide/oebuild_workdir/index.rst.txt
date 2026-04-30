.. _directory_index:

oebuild 工作目录介绍
####################

该章节将介绍oebuild的工作目录结构，以及每个目录的作用。oebuild工作目录的结构如下：

::

  .
  ├── .oebuild
  │   ├── compile.yaml.sample
  │   └── config
  │
  ├── build
  │   └── build_arm64
  │       ├── compile.yaml
  │       └── .env
  │
  └── src
      ├── yocto-meta-openembedded
      ├── yocto-meta-openeuler
      ├── yocto-poky
      └── ......

.oebuild
--------

oebuild全局配置文件存放目录，该目录是隐藏目录。

  **compile.yaml.sample**

    构建配置范例文件，在oebuild对构建配置文件的处理中，可以通过generate命令输入各种参数来生成compile.yaml，也可以通过-c命令直接指定compile.yaml，而compile.yaml.sample是compile.yaml的全参数的范例文件，里面有对所有涉及到的参数的详细说明，由于对compile.yaml的定制命令行参数较多，并不直观，而对配置文件直接进行文本编辑会直观很多，对于该范例文件的使用方法比较简单，直接将该文件拷贝到某个地方，然后重命名为compile.yaml，通过编辑器打开compile.yaml，对该文件做定制化修改，然后直接在generate命令下用-c参数指定即可。关于该文件的详细介绍请参考 :ref:`compile.yaml.sample<configure_index>`。

  **config**

    oebuild全局配置文件，该文件中记录着构建openEuler Embedded的一些准备数据，在执行update、generate，以及bitbake命令时，都会解析该文件。

build
-----

构建统一存放目录，在oebuild的工作目录下，对于镜像构建目录会做统一的管理，而build目录就是用来存放所有创建的构建目录。

  **build_arm64/compile.yaml**

    构建配置文件，每个新创建的构建目录下都会存在一个构建配置文件，其被命名为compile.yaml，而这个文件也是判断该目录是否是构建目录的一个标准。

  **build_arm64/.env**

    构建目录运行环境文件，在oebuild对openEuler Embedded进行构建时会将当下启动的一些环境参数写入到.env中，该文件对构建环境的重复利用起着至关重要的作用。

src
---

源码存放目录，该目录下存放着openEuler Embedded构建下载的所有源码，源码目录的命名以openEuler Embedded的包名为准，例如软件包名为libzip，在openEuler Embedded中该包名称为zip，那么源码包目录名为zip。
