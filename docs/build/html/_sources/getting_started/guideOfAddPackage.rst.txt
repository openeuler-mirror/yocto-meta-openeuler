openEuler新增软件包指导
=========================

1.从零开始写bb
**************************

Ⅰ) 软件包代码放在src
^^^^^^^^^^^^^^^^^^^^

Ⅱ) 在yocto-meta-openeuler仓库meta-openeuler/recipes-xx新增软件包目录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**recipes当前分成4类，recipes-core存放核心软件包bb文件，recipes-devtools存放编译用软件包bb文件，recipes-kernel存放内核bb文件，recipes-labtools存放调试软件包bb文件。**

Ⅲ) 编写bb文件。bb文件名称：<package>_<version>.bb
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Ⅳ) 执行单包编译验证
^^^^^^^^^^^^^^^^^^

.. code-block:: console

    bitbake <package>

Ⅴ) 将包添加到layer
^^^^^^^^^^^^^^^^^^^

**bb文件适配完成并验证ok后，将该软件包追加到layer配置文件IMAGE_INSTALL变量中（ 当前配置文件位于yocto-meta-openeuler工程meta-openeuler /recipes-core/packagegroups/packagegroup-xxx.bb ）。**


2.参考社区移植bb
**************************

Ⅰ) 下载openEuler软件包到src下
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ⅱ) 在yocto-meta-openeuler仓库meta-openeuler/recipes-xx新增软件包目录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**recipes当前分成4类，recipes-core存放核心软件包bb文件，recipes-devtools存放编译用软件包bb文件，recipes-kernel存放内核bb文件，recipes-labtools存放调试软件包bb文件。**

Ⅲ) 搜索并适配修改bb文件。bb文件名称：<package>_<version>.bb
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

①. **搜索yocto-poky仓库是否可以找到相应软件包的bb文件;**

②. **http://layers.openembedded.org/layerindex/branch/master/recipes/，网页中可搜索相应软件包的bb文件。如果未找到相应版本的bb文件，可基于相近版本修改;**

③. **修改bb文件适配openEuler yocto工程，主要需要修改如下字段：**

a) SRC_URI修改源码包来源本地，如果openEuler上该软件包有额外补丁也需要加上；

b) 删除部分inherit、DEPENDS依赖。如texinfo、update-alternatives、python3等，这些class需要引入软件包，暂时没有支持起来。

Ⅳ) 执行单包编译验证
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: console

    bitbake <package>

Ⅴ) 将包添加到layer
^^^^^^^^^^^^^^^^^^^^

**bb文件适配完成并验证ok后，将该软件包追加到layer配置文件IMAGE_INSTALL变量中（ 当前配置文件位于yocto-meta-openeuler工程meta-openeuler /recipes-core/packagegroups/packagegroup-xxx.bb ）。**
