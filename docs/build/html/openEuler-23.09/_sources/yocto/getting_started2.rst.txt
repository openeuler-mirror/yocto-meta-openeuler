.. _yocto_getting_started2:

===================
Yocto 入门文档二
===================

上一章已经安装了Poky，但面对Poky中多如繁花的文件，新用户也是脑袋一晕，不知该如何下手。其实，结合上一篇文章，开发者应该已经对元数据文件有了基本的了解，bitbake运行最基础的文件只有bitbake.conf与base.bbclass，一个配置公共变量，一个配置公共任务，开发者可以在base.bbclass中配置变量，但是不能在bitbake.conf文件配置任务，另外还有层管理的两个配置文件。

如果把所有的功能都放在以上几个文件中，那么会导致这些文件过于庞大，为此，Yocto制定了一套规范将不同的功能拆分到不同的文件中。那么其他的文件是怎么使用的呢？该问题将在这一篇章中得到解答。


.. note:: 
    
    Yocto制定的规范在日常开发时并不强制遵循，因此开发时有很高的自由度，但如果想要使用已存在的功能，那么最好还是遵循规范！

共享功能
===================

Bitbake允许通过 ``.inc`` 和 ``.bbclass`` 文件共享元数据。例如，假设您定义了一个任务，提供了一个公共功能，需要在多个bb之间共享。在这种情况下，创建一个包含通用功能的 ``.bbclass`` 文件，然后在bb中使用 ``inherit`` 指令来继承该类，这是共享任务的常见方式。

首先，开发者需要了解几个指令使用。

==================== ===============================================================
指令                    介绍
==================== ===============================================================
inherit                后接类名，继承类，只能在bbclass与bb文件使用；
include                后接文件全称，若指定文件缺失不会报错；一般不在类文件中使用；
require                与include类似，但找不到指定文件会报错；
INHERIT                与以上三种不同，INHERIT是个变量，只在conf文件使用，配置全局继承的类
==================== ===============================================================

| ``inherit`` 面向的对象的是 ``.bbclass`` 文件，若指定目录存在 :file:`autotools.bbclass` ，则可以通过 ``inherit autotools`` 调用这个类提供的功能；
| ``include`` 面向的对象的是 ``.inc`` 文件，若指定目录存在 :file:`test_defs.inc` ，通过 ``include test_defs.inc`` 调用， ``require`` 相同；
| ``INHERIT`` 面向的对象的是全局的bbclass文件，通过 ``INHERIT += "autotools"`` 调用，将autotools设置为全局类，即所有包都会继承这个类；


除 ``INHERIT`` 之外，使用其他三个指令扩展文件时会在使用处扩展被扩展的文件，举例说明：

此测试基于上一篇章 ``Hello World`` 例子。

  1. 为了方便bitbake构建目标，添加如下行到 :file:`conf/bitbake.conf` ：

  ::

      # bb.parse.vars_from_file是bitbake实现的函数，以下划线为分隔符号，获取bb文件名信息
      PN = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[0] or 'defaultpkgname'}"
      # 根据bb文件名自动生成PV
      PV = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[1] or '1.0'}"

  2. 重新编写 :file:`class/base.bbclass` ：

  ::

      # 定义一个空的build任务
      do_build () {
          :
      }
      # 添加任务
      addtask do_build

  3. 编写 :file:`class/abc.bbclass` ：

  ::

      # 定义TEST_a
      TEST_a = "hello world!"
      # 定义shell任务输出变量TEST_a值
      do_print_hello() {
          echo ${TEST_a}
      }
      # 添加任务依赖，在do_build构建之前执行完成
      addtask do_print_hello before do_build

  4. 编写 :file:`recipes-hello/test-directive_1.0.bb` ：
    
  ::

      # 包的描述信息
      DESCRIPTION = "Test directive!"
      # 继承abc类
      inherit abc
      # 定义TEST_a
      TEST_a = "hello universe!"

  5. bitbake构建目标：

  ::

      $ bitbake test-directive
      # 找到${T}目录，这个目录下会存在很多有用的信息，比如构建日志
      $ cat tmp/test-directive/work/log.do_print_hello
      DEBUG: Executing shell function do_print_hello
      hello universe!
      DEBUG: Shell function do_print_hello finished

最终输出了 ``hello universe!`` ，说明bb文件中的变量定义覆盖了类中的定义，反之如果移动 ``inherit abc`` 的顺序到最后呢？

至此，了解了这些指令的使用，这时你就可以去探索 :file:`bitbake.conf` 和 :file:`base.bbclass` 调用了哪些文件，进行进一步的了解巩固；对了，别忘了扩展的这些文件中也需要搜索上述四个指令，通过以上两文件扩展出的所有文件就是全局使用的配置文件和类文件，也就是构建任何一个包之前都会解析的公共文件；bb文件中定义的以及扩展的其它文件则是此构建独有的配置。 

.. note:: 

    - ``.conf`` 文件也可以使用 ``include`` 、 ``require`` 指令调用，使用方式同 ``.inc`` 文件；
    - 根据解析顺序的先后，可以在解析靠后的文件（如bb文件）实现对解析靠前的文件定义（如conf、bbclass）的部分变量以及任务的覆盖。

Poky结构
===================

Poky目录结构如下： ::

    $ cd yocto-poky
    $ ls
    bitbake               MAINTAINERS.md  meta-skeleton       README.poky.md
    contrib               Makefile        meta-yocto-bsp      README.qemu.md
    documentation         MEMORIAM        oe-init-build-env   scripts
    LICENSE               meta            README.hardware.md
    LICENSE.GPL-2.0-only  meta-poky       README.md
    LICENSE.MIT           meta-selftest   README.OE-Core.md

需要关注的目录文档有 :file:`bitbake、documentation、meta*、oe-init-build-env、scripts` ，下述表格作简要介绍。


==================== ===============================================================
目录/文件                    介绍
==================== ===============================================================
bitbake                bitbake相关python脚本，bitbake相关库，bitbake使用文档等；
documentation          Poky开发的一些文档；
meta*                  层目录，其中meta为核心层，层目录中有bitbake.conf与base.bbclass等；
oe-init-build-env      初始化Yocto构建环境脚本；
scripts                一些额外的shell、python脚本，如QEMU脚本。
==================== ===============================================================


Poky 简单使用
======================

Poky实现meta-poky、meta-yocto-bsp层，增加了发行版的配置。开发者可以通过 :file:`oe-init-build-env` 脚本实现Yocto构建环境的初始化，初始化过程主要包括配置环境变量（BBPATH、PYTHONPATH等）、生成bblayers.conf与local.conf配置文件等。执行步骤如下: ::

    $ cd yocto-poky
    # 在oe-init-build-env目录执行，初始化构建环境
    $ . ./oe-init-build-env <build_dir>
    # 构建目标
    $ bitbake recipe_name

.. note:: 

    初始化环境后用户可以自定义local.conf以及bblayers.conf脚本加入自己的层配置。


总结
============

本章节主要介绍四个指令的作用以及Poky的简单使用，介绍了yocto的共享功能。


参考文献
==================

| poky/documentation/ref-manual/structure.rst
| poky/bitbake/doc/bitbake-user-manual/bitbake-user-manual-metadata.rst
