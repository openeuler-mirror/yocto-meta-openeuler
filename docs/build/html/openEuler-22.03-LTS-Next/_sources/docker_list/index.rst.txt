.. _docker_list:

openEuler Embedded 容器介绍
######################################

该文档介绍openEuler Embedded相关的容器、版本、Dockerfile、容器作用等内容，供想要了解openEuler Embedded项目，参与openEuler Embedded项目的开发人员作容器方向的指导。

- **个人构建容器：swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container**

说明：用于个人对openEuler Embedded进行构建。在22.03-lts版本及之前，容器已铺设好openEuler Embedded所需的一切环境，开发者只需要按 `容器环境下的快速构建指导 <https://openeuler.gitee.io/yocto-meta-openeuler/yocto/quickbuild/container-build.html#id9>`__ 在该容器中下载好代码即可进行构建操作。2203-lts之后版本，因预编译软件不再内置，而是对编译所需软件在容器中进行打包以降低容器大小，因此容器在创建后会自动执行自解压并初始化操作，同时在构建之前需预先执行环境变量初始化操作，命令如下：source
/opt/buildtools/nativesdk/environment-setup-x86_64-pokysdk-linux。构建请参考
`容器环境下的快速构建指导 <https://openeuler.gitee.io/yocto-meta-openeuler/yocto/quickbuild/container-build.html#id9>`__

22.03-lts之后版本容器运行机制如下图：
    .. figure:: ../../image/docker_list/docker_detail.png
        :align: center

        图 1 22.03-lts之后版本容器运行机制

启动容器->自行解压->初始化sdk->初始化环境变量->构建环境初始化完成

+--------------+-------------------------------------+--------------+----------------------------------------------------------------+--------+
| Image        | Base Image                          | Libc Version | Dockerfile                                                     | Remark |
| Version      |                                     |              |                                                                |        |
+==============+=====================================+==============+================================================================+========+
| latest       | openeuler/openeuler:21.03           | 2.31         | `dockerfile <https://gitee.com/openeuler/yocto-embedded-tools/ |        |
|              |                                     |              | /blob/master/dockerfile/Dockerfile>`__                         |        |
+--------------+-------------------------------------+--------------+----------------------------------------------------------------+--------+
| 22.03-lts    | openeuler/openeuler:22.03-lts       | 2.34         | `dockerfile <https://gitee.com/openeuler/yocto-embedded-tools/ |        |
|              |                                     |              | /blob/openEuler-22.03-LTS/dockerfile/Dockerfile>`__            |        |
+--------------+-------------------------------------+--------------+----------------------------------------------------------------+--------+
| 21.09        | openeuler/openeuler:21.03           | 2.31         | `dockerfile <https://gitee.com/openeuler/yocto-embedded-tools/ |        |
|              |                                     |              | /blob/openEuler-21.09/dockerfile/Dockerfile>`__                |        |
+--------------+-------------------------------------+--------------+----------------------------------------------------------------+--------+

- **openEuler基础镜像：swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler**

说明：用于制作openEuler Embedded相关容器

============= ============
Image Version Libc Version
============= ============
22.03-lts     2.34
21.03         2.31
20.03         2.31
============= ============
