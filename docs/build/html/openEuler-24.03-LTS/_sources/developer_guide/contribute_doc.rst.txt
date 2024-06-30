.. _contribute_doc:

文档提交指导
##################

openEuler Embedded采用Sphinx来构建文档，生成html静态页面，并最终托管在gitee pages上。
本章主要简述如何通过Sphinx向openEuler Embedded贡献文档。

关于Sphinx
===========

这里直接引用sphinx官方网站 [#sphinx_web]_ 上的介绍：

::

    Sphinx是一个工具，可以轻松地创建出智慧且优雅的文档。它由Georg Brandl创建，并在BSD许可证下授权。
    它最初是为Python文档创建的。它具有出色的功能，可用于各种语言的软件项目文档

    输出格式: HTML（包括Windows HTML帮助），LaTeX（可打印的PDF版本），ePub，Texinfo，手册页，纯文本
    丰富的交叉引用: 语义标记以及针对函数，类，引用，词汇表（术语）和相似的信息块的自动链接
    层次结构: 简单的文本树定义，就能自动地链接到同层（兄弟姐妹）、上一层（父母）以及下一层（子女）的文本位置
    自动生成目录: 通用索引以及语言模块的目录
    代码高亮: 使用Pygments荧光笔使代码自动高亮
    扩展功能: 自动测试代码片段，包括从Python模块（API文档）中的文档字符串
    贡献的扩展: 用户在第二个存储库中贡献了50多个扩展，其中大多数可以通过PyPI安装

更多的使用细节可以前往 `官方网站 <https://www.sphinx-doc.org/en/master/>`_ 查找

关于reStructuredText语法
===============================

依据维基百科 [#rst_wikipedia]_ 的介绍::

    reStructuredText（RST、ReST或reST）是一种用于文本数据的文件格式，主要用于 Python 编程语言社区的技术文档。
    它是Python Doc-SIG（Documentation Special Interest Group）的Docutils项目的一部分，旨在为Python创建
    一组类似于 Java 的 Javadoc 或 Perl 的 Plain Old Documentation（pod）的工具。Docutils可以从Python程序
    中提取注释和信息，并将它们格式化为各种形式的程序文档。

reStructuredText的语法与Markdown十分类似，但能以更加结构化的方式撰写专业文档，vscode中也有相应的插件提供辅助。
reStructuredText的语法无需专门记忆，用时查询即可，具体可参考 [#rst_tutorial]_ 。

如何贡献文档（Linux环境）
==============================

* git clone yocto-meta-openeuler仓库

    .. code-block:: bash

        git clone https://gitee.com/openeuler/yocto-meta-openeuler.git

* 环境准备

    如果只进行文档开发，那么需要准备好python3， 然后通过pip3按照如下命令安装对应python软件包，包括sphinx、文档主题等：

    .. code-block:: bash

        pip3 install --user -r yocto-meta-openeuler/scripts/requirements-doc.txt

* 编辑文档

    相关文档源码位于 :file:`docs/source` 目录，根据需要修改或新增相应文档，新增文档命名需按照Linux命名规则命名为xxx_yyy_zzz.rst。请按照如下目录规则布局文档:

    .. csv-table:: 文档目录布局
        :header: "文件/目录名", "用途"
        :widths: 20, 20

        "index.rst", "目录页"
        "introduction", "openEuler Embedded总揽与简介"
        "getting_started", "openEuler Embedded快速使用入门"
        "features", "openEuler Embedded主要特性介绍"
        "linux", "openEuler Embedded运行相关的内容说明"
        "infrastructure", "openEuler Embedded基础设施相关内容"
        "yocto", "openEuler Embedded的Yocto构建系统"
        "develop_help", "涉及openEuler Embedded开发过程中的一些帮助指导"
        "bsp", "openEuler Embedded南向支持方面的内容"
        "release", "openEuler Embedded的发布说明"

*  编译文档

   在 :file:`docs` 目录下编译文档：

    .. code-block:: bash

        make html

    编译成功后，可以切换到gitee_pages分支，打开 :file:`docs/build/html/*.html` 查看最终生成的网页形式的文档。

* 提交修改

  和提交代码类似，将所有修改通过commit的形式提交，然后在gitee上创建PR提交到openEuler Embedded对应的仓库，经过审查后，
  修改就会被CI自动编译并发布。

  .. attention::

   - 新增文档必须将该文档加入到对应目录的index索引文件中，新增目录必须将目录和索引加入到 :file:`docs/source/getting_started/index.html` 中，图片加入到 :file:`docs/image/` 目录中。
   - git提交时标题加上 :file:`doc:` 开头，例如doc:(空一格)modify doc。并加上Signed-off-by，与提交的message中间空一行。
   - 提交PR时标题要以  :file:`[文档]` 开头，例如[文档]：修改xx文档内容。如果有issue，要和issue进行关联。

如何贡献文档（Windows环境）
================================

* git clone yocto-meta-openeuler仓库

    .. code-block:: bash

        git clone https://gitee.com/openeuler/yocto-meta-openeuler.git

* 环境准备

sphinx依赖于python，所以要先安装python环境，并安装pip工具和sphinx。

1.下载并安装python3 for windows：https://www.python.org/downloads/windows/

- 下载python3安装包

- 安装python3，默认安装或自定义安装路径如 :file:`D:/python3`

- 添加到系统路径，如python3安装到 :file:`D:/python3` 下，则将 :file:`D:/Python3` 和 :file:`D:/Python3/Scripts` 添加到系统环境变量Path中，后面那个路径一般是easy_install，pip等扩展工具安装的目录。

- 安装pip3，默认pip3已经在 :file:`Scripts` 目录中（安装python3时自带），故无需额外安装。如果没有，则下载并安装：

  - 下载 :file:`get-pip.py` 脚本到 :file:`Scripts` 目录，地址： https://bootstrap.pypa.io/get-pip.py

  - 在 :file:`Scripts` 目录运行下面命令安装pip3：

      .. code-block:: python

          python3 get-pip.py

2.使用pip3安装sphinx（运行此命令）:

    .. code-block:: bash

        pip3 install sphinx

3.在python的 :file:`Scripts` 目录下，找到easy_install（如没有则需额外安装），在命令行输入

    .. code-block:: bash

        easy_install sphinx

easy_install可以自动下载并安装sphinx以及它所依赖的其他模块。

4.安装完成后，命令行会提示`Finished Processing dependencies for sphinx`。

5.在命令行输入sphinx-build以查看安装结果。如果安装python时没有设置环境变量，可能会提示“sphinx-build不是内部或者外部命令”。

6.通过pip3按照如下命令安装相应的python软件包，包括sphinx、文档主题等：

    .. code-block:: bash

        pip3 install --user -r yocto-meta-openeuler/scripts/requirements-doc.txt

*  创建工程

安装完sphinx后，会在python的 :file:`Scripts` 目录下产生sphinx-quickstart，确保该目录已经添加到系统环境变量中。

1.启动cmd。进入要创建sphinx文档的目录，如 :file:`D:/Learn/python` 。

    .. code-block:: bash

        cd /d d:\Learn\python

或直接在 :file:`D:/Learn/python` 目录下，按住Shift，点击鼠标右键选择在此处打开Powershell窗口(S)。

2.执行下面过程，创建编写Python文档的工程，只需设置工程名、作者名、版本号，其他默认即可。方便起见，此处将source和build两个目录分开。

    .. code-block:: bash

        PS D:\Learn\python> sphinx-quickstart
        Welcome to the Sphinx 3.5.4 quickstart utility.

        Please enter values for the following settings (just press Enter to accept a default value, if one is given in brackets).

        Selected root path: .

        You have two options for placing the build directory for Sphinx output.
        Either, you use a directory "_build" within the root path, or you separate "source" and "build" directories within the root path.

        > Separate source and build directories (y/n) [n]: y

        The project name will occur in several places in the built documentation.

        > Project name: embedded
        > Author name(s): yang
        > Project release []: 1.0.0

        If the documents are to be written in a language other than English, you can select a language here by its language code. Sphinx will then translate text that it generates into that language.

        For a list of supported codes, see https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-language.

        > Project language [en]:

        Creating file D:\Learn\python\source\conf.py.
        Creating file D:\Learn\python\source\index.rst.
        Creating file D:\Learn\python\Makefile.
        Creating file D:\Learn\python\make.bat.

        Finished: An initial directory structure has been created.

        You should now populate your master file D:\Learn\python\source\index.rst and create other documentation source files. Use the Makefile to build the docs, like so:
           make builder
        where "builder" is one of the supported builders, e.g. html, latex or linkcheck.

        PS D:\Learn\python>

安装完成后，将clone的 :file:`yocto-meta-openeuler/docs/` 目录下的 :file:`image` 和 :file:`source` 目录全部复制到新建工程目录（ :file:`D:/Learn/python` ）内并替换原文件。

* 编辑文档

相关文档源码位于 :file:`docs/source` 目录，根据需要修改或新增相应的文档，新增文档需按照Linux命名方法命名为xxx_yyy_zzz.rst，请按照如下目录规则布局文档:

    .. csv-table:: 文档目录布局
        :header: "文件/目录名", "用途"
        :widths: 20, 20

        "index.rst", "目录页"
        "introduction", "openEuler Embedded总揽与简介"
        "getting_started", "openEuler Embedded快速使用入门"
        "features", "openEuler Embedded主要特性介绍"
        "linux", "openEuler Embedded运行相关的内容说明"
        "infrastructure", "openEuler Embedded基础设施相关内容"
        "yocto", "openEuler Embedded的Yocto构建系统"
        "develop_help", "涉及openEuler Embedded开发过程中的一些帮助指导"
        "bsp", "openEuler Embedded南向支持方面的内容"
        "release", "openEuler Embedded的发布说明"


*  编译文档

将 :file:`docs` 下的 :file:`image` 和 :file:`source` 目录内新增和修改的文件全部复制替换到工程（:file:`D:/Learn/python`）对应目录内，在该目录下编译文档：

    .. code-block:: bash

        .\make html

编译成功之后，可以打开 :file:`build/html` 目录下的html文件查看最终生成的网页形式的文档。

* 提交修改

像提交代码一样，将所有修改通过commit的形式提交，然后在gitee上创建PR提交到openEuler Embedded对应的仓库, 经过审查后，修改就会被CI自动编译并发布。

  .. attention::

   - 新增文档必须将该文档加入到对应目录的index索引文件中，新增目录必须将目录和索引加入到 :file:`docs/source/getting_started/index.html` 中，图片加入到 :file:`docs/image/` 目录中。
   - git提交时标题加上 :file:`doc:` 开头，例如doc:(空一格)modify doc。并加上Signed-off-by，与提交的message中间空一行。
   - 提交PR时标题要以  :file:`[文档]` 开头，例如[文档]：修改xx文档内容。如果有issue，要和issue进行关联。

.. [#sphinx_web] `Sphinx官方网站 <https://www.sphinx-doc.org/en/master/>`_
.. [#rst_wikipedia] `reStructuredText维基百科 <https://zh.wikipedia.org/wiki/ReStructuredText>`_
.. [#rst_tutorial] `reStructuredText简易教程 <https://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html>`_