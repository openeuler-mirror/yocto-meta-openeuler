.. _bitbake_and_metadata:

===================
Bitbake 与 元数据
===================

yocto工程的主要组成部分是bitbake工具与元数据。bitbake是一个通用任务执行引擎，元数据文件主要分为conf、bbclass、bb文件。bitbake与元数据的关系类似于gcc与c代码。

一门新的语言的学习往往从编写 ``hello world`` 开始，bitbake也是如此。本教程介绍了如何创建一个yocto项目以及bitbake构建该项目所需的适用元数据文件。以下从一个新用户的角度来使用bitbake工具构建 ``hello world`` 程序。

本节将通过编写一个简单的 ``printhello.bb`` 探讨bitbake与元数据文件之间的关联。

.. note:: 
    
    小知识：bitbake英文直译为烘培，bb文件也被称为recipe文件，意为食谱、配方。bitbake构建目标的主要形式是 ``bitbake recipe_name``，组合在一起意思就是根据食谱完成烘培。


一、获取 BitBake
====================

| Bitbake官网链接：https://github.com/openembedded/bitbake
| 建议下载Poky仓库，Poky是yocto工程的一个参考发行版，仓库中配套了对应的bitbake程序。步骤如下：

::

    $ git clone https://git.yoctoproject.org/poky
    $ cd poky/bitbake

如下载速度过慢，可以选择浅克隆指定分支代码下载或者从openEuler下载。步骤如下：

::

    $ git clone https://gitee.com/openeuler/yocto-poky.git -b v4.0.10
    $ cd yocto-poky/bitbake

以下测试以openEuler上下载的yocto-poky仓库为例。

.. note:: 

    BitBake最初是OpenEmbedded项目的一部分。2004年，OpenEmbedded项目被拆分为BitBake与OpenEmbedded（元数据集）。
    Poky在结合bitbake与OpenEmbedded部分的基础上，创建了自己的发行版。


二、配置 BitBake 运行环境
============================

将bitbake路径添加到shell环境中，以便能从任何目录运行bitbake。 ::

    $ export PATH=/path/to/bitbake/bin:$PATH
    $ bitbake --version
    BitBake Build Tool Core version 1.50.0

.. note:: 

    /path/to/为目录实际路径。


三、编写 Hello World 示例
===========================

1.  **创建工程目录：** 创建一个目录，bitbake在此目录完成所有的构建工作。

  家目录创建 :file:`hello/` 文件夹。 ::

      $ mkdir $HOME/hello
      $ cd $HOME/hello


2.  **运行 bitbake：** 在 :file:`hello/` 目录运行bitbake，当前目录为空。

  ::

      $ bitbake
      ERROR: Unable to find conf/bblayers.conf or conf/bitbake.conf. BBPATH is unset and/or not in a build directory?

  前半段错误提示缺失相关文件，后半段提示没有配置BBPATH变量或者是没有在构建目录中。


3.  **设置 BBPATH：** BBPATH与PATH使用方法类似，bitbake在BBPATH设置路径下查找需要的 :file:`conf/xxx.conf` 文件，若没有设置，则在当前目录查找需要的文件。 

  设置BBPATH为工程目录。 ::

      $ BBPATH="$HOME/hello"
      $ export BBPATH
      $ bitbake
      ERROR: Unable to find conf/bblayers.conf or conf/bitbake.conf. BBPATH is unset and/or not in a build directory?

  相同的错误。


4.  **创建 conf/bitbake.conf：** bitbake.conf是yocto的底层配置文件，配置主要的变量。

  工程目录创建一个空的 :file:`conf/bitbake.conf` 文件。 ::

      $ mkdir conf
      $ touch conf/bitbake.conf
      ERROR: ParseError in configuration INHERITs: Could not inherit file classes/base.bbclass

  错误提示缺失 :file:`classes/base.bbclass` 文件。


5.  **创建 classes/base.bbclass：** base.bbclass是类文件，yocto配置通用任务的必需文件。

  工程目录创建一个空的 :file:`classes/base.bbclass` 文件。 ::

      $ mkdir classes
      $ touch classes/base.bbclass
      $ bitbake
      ERROR: Please set the 'PERSISTENT_DIR' or 'CACHE' variable

  错误提示没有配置相关变量。


6.  **配置必要的变量：** bitbake.conf文件是yocto的底层配置文件，其中定义了大部分构建需要的变量，如PN、PV、CFLAGS、PATH等等，此处仅配置构建需要的最基本变量。

  编写 :file:`conf/bitbake.conf` 文件，添加如下行： ::

      # bitbake根据找到的conf文件路径自动生成TOPDIR变量
      # 临时变量，为了方便配置，也可以不设置
      TMPDIR  = "${TOPDIR}/tmp"
      # 指定BitBake用于存储元数据缓存的目录，这样就不需要每次启动BitBake时都对其进行解析。
      CACHE = "${TMPDIR}/cache"
      # 指定用于创建配方戳文件的基本路径。实际戳文件的路径是通过对该字符串求值，然后附加附加信息来构建的。
      STAMP   = "${TMPDIR}/${PN}/stamps"
      # 指向BitBake在构建特定配方时放置临时文件的目录，这些文件主要由任务日志和脚本组成。
      T = "${TMPDIR}/${PN}/work"
      $ bitbake
      Nothing to do.  Use 'bitbake world' to build everything, or run 'bitbake --help' for usage information.

  至此，运行bitbake命令成功。然而，你可以发现bitbake其实没有做任何事情，这时需要创建一个bb文件让bitbake去完成一些任务。


7.  **创建一个层（layer）：** 层是元数据的集合。

  在这样一个小的例子创建一个层并不那么必要，但创建一个层是一个好的实践，方便保持你的代码独立于bitbake使用的通用元数据。 ::

      $ cd $HOME
      $ mkdir meta-mylayer
      $ cd meta-mylayer
      $ mkdir conf
      $ cd conf

  一个层中必须存在 :file:`conf/layer.conf` 文件，定义层bb文件所在位置等。编写 :file:`conf/layer.conf` 文件，添加如下行： ::

      # 添加BBPATH路径，LAYERDIR表示当前层的路径
      BBPATH .= ":${LAYERDIR}"
      # 添加路径，查找bb文件；'*'是任意匹配符
      BBFILES += "${LAYERDIR}/recipes-*/*.bb"
      # 当前配置层的名称，可自定义
      BBFILE_COLLECTIONS += "mylayer"
      BBFILE_PATTERN_mylayer := "^${LAYERDIR}/"
      # 当前层的优先级
      BBFILE_PRIORITY_mylayer = "5"

  .. note::

      - 层命名习惯以 ``meta-`` 开头；
      - 如果不想创建一个层可以将下述语句添加到 :file:`bitbake.conf` 中，以便构建时能找到对应的bb文件。
          
          ``BBFILES += "/path/to/*.bb"``


8.  **创建一个bb文件：** bb文件定义此目标需要完成的任务。

  编写 :file:`recipes-hello/printhello.bb` 文件，添加如下内容： ::

      # 包的描述信息
      DESCRIPTION = "Prints Hello World"
      # 定义包名，bitbake $PN
      PN = "printhello"
      # 包的版本号
      PV = "1"

      # 定义一个python任务，输出"Hello, World!"
      # 也可以定义shell任务，去除do_build前的python即可，使用shell语法进行打印输出，这里不作例子
      python do_build() {
          # bb.plain是yocto实现的打印函数，根据打印信息要求还有debug、warn、error等
          bb.plain("********************");
          bb.plain("*                  *");
          bb.plain("*  Hello, World!   *");
          bb.plain("*                  *");
          bb.plain("********************");
      }
      # 添加任务
      addtask do_build
      
  .. note::

      ``do_build`` 是yocto默认执行的任务。如果定义为其它的任务名执行时需要加上-c的参数，执行如下：
          
          ``bitbake recipe_name -c task_name``


9.  **运行bitbake构建目标：** 

  ::

      $ cd $HOME/hello
      $ bitbake printhello
      ERROR: no recipe files to build, check your BBPATH and BBFILES?
      Loading cache: 100% |                                                                                                       | ETA:  --:--:--
      Loaded 0 entries from dependency cache.
      ERROR: Nothing PROVIDES 'printhello'

      Summary: There were 2 ERROR messages shown, returning a non-zero exit code.

  错误提示找不到bb文件，显然我们并没有对构建路径（hello/）与所加层的路径（meta-mylayer/）添加关联。


10.  **创建conf/bblayers.conf：** bitbake使用 :file:`conf/bblayers.conf` 文件去定位工程构建时所用到的层。

  编写 :file:`conf/bblayers.conf` 文件，添加内容如下： ::

      # 列出构建时用到的层
      BBLAYERS ?= " \
          /path/to/meta-mylayer \
      "


11.  **再次运行bitbake构建目标：** 

  ::

      $ cd $HOME/hello
      $ bitbake printhello
      Parsing recipes: 100% |######################################################################################################| Time: 0:00:00
      Parsing of 1 .bb files complete (0 cached, 1 parsed). 1 targets, 0 skipped, 0 masked, 0 errors.
      NOTE: Resolving any missing task queue dependencies
      Initialising tasks: 100% |###################################################################################################| Time: 0:00:00
      NOTE: No setscene tasks
      NOTE: Executing Tasks
      ********************
      *                  *
      *  Hello, World!   *
      *                  *
      ********************
      NOTE: Tasks Summary: Attempted 1 tasks of which 0 didn't need to be rerun and all succeeded.

  构建成功。如果再次运行 bitbake printhello 将不会打印相同的输出，原因是，当printhello.bb配方的do_build任务第一次成功执行时，BitBake会为该任务写入一个stamp文件。因此下次尝试使用相同的bitbake命令运行任务时，bitbake会注意到戳，因此确定不需要重新运行任务。如果删除tmp目录然后重新运行构建，将再次打印"Hello, World!"消息。

  最终目录结构如下：::

      $ tree hello/
      hello/
      ├── classes
      │   └── base.bbclass
      └── conf
          ├── bblayers.conf
          └── bitbake.conf

      $ tree meta-mylayer/
      meta-mylayer/
      ├── conf
      │   └── layer.conf
      └── recipes-hello
          └── printhello.bb

  .. note:: 

      到此，是否注意到 :file:`base.bbclass` 没有任何内容，试着把 :file:`printhello.bb` 中的 ``do_build`` 任务定义与 ``addtask build`` 移到 :file:`base.bbclass` 重新构建试试；下一步创建一个新的bb，这个bb并不需要添加 ``addtask build`` 语句也可以执行 ``do_build`` 任务。


小结
======

- yocto项目依托于bitbake工具，存在了比较完善的元数据文件，包括bitbake.conf与base.bbclass，这两个文件在 `OpenEmbedded <https://git.openembedded.org/openembedded-core/tree/meta>`_ 中已有定义，用户可以在此基础上进行开发。在初步接触到yocto项目时，用户总会感慨这个项目的庞大，本文档从bitbake工具开始，从根剖析，完成了一个helloworld程序，当学习yocto工程的语法后，用户会了解到工程中大部分的文件都是通过bitbake.conf与base.bbclass文件运行的。

- bblayers.conf与layer.conf作用是管理层文件，当进行某一个项目开发时，独立的层更加易于模块化实现。通过这种模块化设计，开发者可以更容易地管理和扩展他们的项目，确保各个功能组件的独立性和可重用性。
