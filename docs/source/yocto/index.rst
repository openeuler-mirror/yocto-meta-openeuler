.. _yocto:

构建系统
============================

由于openEuler Embedded是面向嵌入式场景的，其对构建系统的核心诉求是： **交叉编译、灵活的定制化与裁剪**，
而openEuler现有的OBS构建系统更加适合服务器场景的大型OS构建，无法有效满足嵌入式场景的需求，所以
openEuler Embeddedd的核心构建系统是基于Yocto，但又根据自身的需求做了很多定制化的开发。

本章主要介绍openEuler Embedded构建系统，具体内容如下：

.. toctree::
   :maxdepth: 1

   getting_started.rst
   getting_started2.rst
   getting_started3.rst
   overview.rst
   meta-openeuler.rst
   exploration.rst
   development.rst
   poky4.0.rst
   addpackage_guide.rst
   container_environment.rst
   priority.rst
   sstate.rst
   devshell.rst
   partitioned_image.rst
   openeuler_src_uri_remove.rst
