.. _contribute_doc:

如何撰写并贡献文档
##################

openEuler Embedded采用了Sphinx来构建文档，生成html静态面，并最终托管在gitee pages上。
本章主要简述如何通过Sphinx向openEuler Embedded贡献文档。

关于Sphinx
===========

这里直接引用sphinx官方网站 [#sphinx_web]_ 上的介绍：

::

    Sphinx是一个工具，可以轻松创建由Georg Brandl编写并根据BSD许可证授权的智能和美观文档
    它最初是为Python文档创建的，它具有出色的工具，可用于各种语言的软件项目文档

    输出格式: HTML（包括Windows HTML帮助），LaTeX（适用于可打印的PDF版本），ePub，
    Texinfo，手册页，纯文本

    广泛的交叉引用: 语义标记和功能，类，引用，词汇表术语和类似信息的自动链接
    分层结构: 轻松定义文档树，自动链接到平级，上级和下级
    自动索引: 一般索引以及特定于语言的模块索引
    代码处理: 使用Pygments荧光笔自动突出显示
    扩展: 自动测试代码片段，包含Python模块（API文档）中的文档字符串等
    贡献的扩展: 用户在第二个存储库中贡献了50多个扩展;其中大多数可以从PyPI安装

更多的使用细节可以前往其 `官方网站 <https://www.sphinx.org.cn/index.html>`_ 查找

关于reStructuredText语法
===============================

依据维基百科 [#rst_wikipedia]_ 的介绍::

    reStructuredText（RST、ReST或reST）是一种用于文本数据的文件格式，主要用于 Python 编程语言社区的技术文档。
    它是Python Doc-SIG（Documentation Special Interest Group）的Docutils项目的一部分，旨在为Python创建
    一组类似于 Java 的 Javadoc 或 Perl 的 Plain Old Documentation（pod）的工具。Docutils可以从Python程序
    中提取注释和信息，并将它们格式化为各种形式的程序文档

reStructuredText的语法与Markdown十分类似，但能以更好的结构化的方式撰写专业文档，vscode中也有相应的插件提供辅助。
reStructuredText的语法无需专门记忆，需要用到时再去查询即可，具体可以参考 [#rst_tutorial]_ 。

如何贡献文档
==================

* git clone yocto-meta-openeuler仓库

    .. code-block:: bash

        git clone https://gitee.com/openeuler/yocto-meta-openeuler.git

* 环境准备

    如果你只是开发文档的话，那么你需要准备好python3, 然后通过pip3按照如下命令安装相应的python软件包，包括sphinx、文
    档主题等：

    .. code-block:: bash

        pip3 install --user -r yocto-meta-openeuler/scripts/requirements-doc.txt

* 编辑文档

    相关文档源码位于 :file:`docs/source` 目录，根据你的需要修改或新增相应的文档，请按照如下目录规则布局文档:

    .. csv-table:: 文档目录布局
        :header: "文件/目录名", "用途"
        :widths: 20, 20

        "index.rst", "目录页"
        "introduction", "openEuler Embedded总揽与简介"
        "getting_started", "openEuler Embedded快速使用入门"
        "features", "openEuler Embedded主要特性介绍"
        "yocto", "openeuler Embedded的Yocto构建系统"
        "release", "openEuler Embedded的发布说明"

*  编译文档

   在 :file:`docs` 目录下编译文档

    .. code-block:: bash

        make html

    编译成功之后，可以打开 :file:`docs/build/html/index.html` 查看最终生成的网页形式的文档。

* 提交修改

  像提交代码一样，把所有的修改以commit的形式提交，然后在gitee上生成PR提交到openEuler Embedded对应的仓库, 经过审查后，
  修改就会被CI自动编译并发布。

.. [#sphinx_web] `Sphinx官方网站 <https://www.sphinx.org.cn/index.html>`_
.. [#rst_wikipedia] `reStructuredText维基百科 <https://zh.wikipedia.org/wiki/ReStructuredText>`_
.. [#rst_tutorial] `reStructuredText简易教程 <https://www.sphinx.org.cn/usage/restructuredtext/basics.html>`_